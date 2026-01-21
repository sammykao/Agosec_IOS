import SwiftUI
import UIKit
import Photos
import SharedCore
import Networking
import OCR
import UIComponents

struct AgentKeyboardView: View {
    let onClose: () -> Void
    let textDocumentProxy: UITextDocumentProxy
    
    @StateObject private var sessionManager = AgentSessionManager()
    @State private var currentStep: AgentStep = .introChoice
    @State private var isLoading = false
    @State private var loadingMessage = ""
    @State private var error: Error?
    @EnvironmentObject var toastManager: ToastManager
    
    enum AgentStep {
        case introChoice
        case chat(session: ChatSession)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
                .frame(height: 44)
                .background(Color.clear)
            
            mainContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.clear)
        .toastOverlay(toastManager: toastManager)
    }
    
    private var headerView: some View {
        ZStack {
            // Centered title
            Text("Agosec Agent")
                .font(.system(size: 18, weight: .semibold, design: .default))
                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.2))
            
            // Left button
            HStack {
                Button(action: {
                    print("🔙 Back button tapped - closing agent mode")
                    onClose()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
        }
        .padding(.horizontal, 8)
        .frame(height: 44)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private var mainContent: some View {
        ZStack {
        switch currentStep {
        case .introChoice:
            AgentIntroView(
                onChoiceMade: { choice in
                    handleIntroChoice(choice)
                },
                onClose: onClose
            )
            .environmentObject(toastManager)
            case .chat(let session):
                AgentChatView(
                    session: session,
                    textDocumentProxy: textDocumentProxy,
                    onNewSession: {
                        currentStep = .introChoice
                    }
                )
                .id(session.sessionId)
                .environmentObject(toastManager)
            }
            
            // Loading overlay
            if isLoading {
                LoadingOverlay(message: loadingMessage)
            }
        }
    }
    
    private func handleIntroChoice(_ choice: IntroChoice) {
        isLoading = true
        
        switch choice {
        case .useAndDeleteScreenshots(_, _), .useScreenshots(_):
            loadingMessage = "Processing screenshots..."
        case .continueWithoutContext:
            loadingMessage = "Starting conversation..."
        }
        
        Task {
            do {
                let session = try await sessionManager.initializeSession(choice: choice)
                await MainActor.run {
                    isLoading = false
                    currentStep = .chat(session: session)
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    let message = ErrorMapper.userFriendlyMessage(from: error)
                    let shouldRetry = ErrorMapper.shouldShowRetry(for: error)
                    
                    toastManager.show(
                        message,
                        type: .error,
                        duration: shouldRetry ? 5.0 : 3.0,
                        retryAction: shouldRetry ? {
                            handleIntroChoice(choice)
                        } : nil
                    )
                }
            }
        }
    }
}

enum IntroChoice {
    case useAndDeleteScreenshots([UIImage], [String]) // images and asset identifiers
    case useScreenshots([UIImage])
    case continueWithoutContext
}

class AgentSessionManager: ObservableObject {
    private let chatAPI: ChatAPIProtocol?
    private let ocrService: OCRServiceProtocol
    
    init() {
        // Use ServiceFactory to get appropriate service (mock or real)
        let accessToken: String? = AppGroupStorage.shared.get(String.self, for: "access_token")
        
        // In mock mode, we can create ChatAPI even without access token
        if BuildMode.isMockBackend {
            self.chatAPI = ServiceFactory.createChatAPI(
                baseURL: Config.shared.backendBaseUrl,
                accessToken: accessToken,
                sessionId: nil
            )
            // Use REAL OCR service in mock mode so user can see actual extracted text
            self.ocrService = OCRService()
        } else {
            // Real mode requires access token
            if let accessToken = accessToken {
                self.chatAPI = ServiceFactory.createChatAPI(
                    baseURL: Config.shared.backendBaseUrl,
                    accessToken: accessToken,
                    sessionId: nil
                )
            } else {
                self.chatAPI = nil
            }
            self.ocrService = OCRService()
        }
    }
    
    func initializeSession(choice: IntroChoice) async throws -> ChatSession {
        var session = ChatSession()
        
        switch choice {
        case .useAndDeleteScreenshots(let images, let assetIdentifiers):
            let context = try await extractContext(from: images)
            
            // In mock backend mode, display the extracted OCR text directly
            if BuildMode.isMockBackend {
                // Show the raw extracted text so user can see what was extracted
                let extractedText = context.rawText
                let displayText = """
                📸 **OCR Extracted Text:**
                
                \(extractedText)
                
                ---
                *This is the text extracted from your screenshots. In production mode, this would be sent to the AI for context.*
                """
                let turn = ChatTurn(role: .assistant, text: displayText)
                session.turns.append(turn)
            } else {
                // Real mode: send to API for summary
                let summary = try await fetchSummary(session: session, context: context)
                let turn = ChatTurn(role: .assistant, text: summary)
                session.turns.append(turn)
            }
            
            // Delete photos after processing
            await deletePhotos(assetIdentifiers: assetIdentifiers)
            
        case .useScreenshots(let images):
            let context = try await extractContext(from: images)
            
            // In mock backend mode, display the extracted OCR text directly
            if BuildMode.isMockBackend {
                // Show the raw extracted text so user can see what was extracted
                let extractedText = context.rawText
                let displayText = """
                📸 **OCR Extracted Text:**
                
                \(extractedText)
                
                ---
                *This is the text extracted from your screenshots. In production mode, this would be sent to the AI for context.*
                """
                let turn = ChatTurn(role: .assistant, text: displayText)
                session.turns.append(turn)
            } else {
                // Real mode: send to API for summary
                let summary = try await fetchSummary(session: session, context: context)
                let turn = ChatTurn(role: .assistant, text: summary)
                session.turns.append(turn)
            }
            
        case .continueWithoutContext:
            // In mock backend mode, display mock intro message directly
            if BuildMode.isMockBackend {
                // Show mock intro message without calling API
                let mockIntro = "Hi! I'm your AI assistant. I can help you write messages, answer questions, and provide context-aware responses. What can I help you with today?"
                let turn = ChatTurn(role: .assistant, text: mockIntro)
                session.turns.append(turn)
            } else {
                // Real mode: call API for intro
                let intro = try await fetchIntro(session: session)
                let turn = ChatTurn(role: .assistant, text: intro)
                session.turns.append(turn)
            }
        }
        
        return session
    }
    
    private func extractContext(from images: [UIImage]) async throws -> ContextDoc {
        return try await ocrService.extractText(from: images)
    }
    
    private func fetchSummary(session: ChatSession, context: ContextDoc) async throws -> String {
        guard let chatAPI = chatAPI else {
            throw AgentError.noAPIAccess
        }
        
        let response = try await chatAPI.sendMessage(
            sessionId: session.sessionId,
            initMode: .summarizeContext,
            turns: session.turns,
            context: context,
            fieldContext: nil
        )
        
        return response.reply
    }
    
    private func fetchIntro(session: ChatSession) async throws -> String {
        guard let chatAPI = chatAPI else {
            throw AgentError.noAPIAccess
        }
        
        let response = try await chatAPI.sendMessage(
            sessionId: session.sessionId,
            initMode: .noContextIntro,
            turns: session.turns,
            context: nil,
            fieldContext: nil
        )
        
        return response.reply
    }
    
    private func deletePhotos(assetIdentifiers: [String]) async {
        guard !assetIdentifiers.isEmpty else { return }
        
        // Check authorization
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        guard status == .authorized || status == .limited else {
            print("⚠️ Cannot delete photos: insufficient authorization (status: \(status.rawValue))")
            return
        }
        
        // Fetch PHAsset objects from identifiers
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: assetIdentifiers, options: nil)
        guard fetchResult.count > 0 else {
            print("⚠️ No assets found for deletion")
            return
        }
        
        var assetsToDelete: [PHAsset] = []
        fetchResult.enumerateObjects { asset, _, _ in
            assetsToDelete.append(asset)
        }
        
        // Delete assets
        do {
            try await PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.deleteAssets(assetsToDelete as NSArray)
            }
            print("✅ Successfully deleted \(assetsToDelete.count) photo(s)")
        } catch {
            print("❌ Failed to delete photos: \(error.localizedDescription)")
            // Don't throw - deletion failure shouldn't block the session
        }
    }
}

enum AgentError: Error {
    case noAPIAccess
    case invalidContext
    
    var localizedDescription: String {
        switch self {
        case .noAPIAccess:
            return "AgentError.noAPIAccess"
        case .invalidContext:
            return "AgentError.invalidContext"
        }
    }
}