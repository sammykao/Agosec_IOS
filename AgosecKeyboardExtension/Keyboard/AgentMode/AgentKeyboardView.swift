import SwiftUI
import UIKit
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
                .background(Color.gray.opacity(0.1))
            
            mainContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(UIColor.systemBackground))
    }
    
    private var headerView: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 18))
                    .foregroundColor(.primary)
                    .padding(8)
            }
            
            Spacer()
            
            Text("Agosec Agent")
                .font(.system(size: 16, weight: .semibold))
            
            Spacer()
            
            Button(action: { currentStep = .introChoice }) {
                Image(systemName: "plus")
                    .font(.system(size: 18))
                    .foregroundColor(.primary)
                    .padding(8)
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var mainContent: some View {
        ZStack {
        switch currentStep {
        case .introChoice:
            AgentIntroView { choice in
                handleIntroChoice(choice)
            }
            .environmentObject(toastManager)
            case .chat(let session):
                AgentChatView(
                    session: session,
                    textDocumentProxy: textDocumentProxy,
                    onNewSession: {
                        currentStep = .introChoice
                    }
                )
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
        case .useAndDeleteScreenshots, .useScreenshots:
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
    case useAndDeleteScreenshots([UIImage])
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
            self.ocrService = MockOCRService()
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
        let session = ChatSession()
        
        switch choice {
        case .useAndDeleteScreenshots(let images),
             .useScreenshots(let images):
            let context = try await extractContext(from: images)
            let summary = try await fetchSummary(session: session, context: context)
            let turn = ChatTurn(role: .assistant, text: summary)
            session.turns.append(turn)
            
        case .continueWithoutContext:
            let intro = try await fetchIntro(session: session)
            let turn = ChatTurn(role: .assistant, text: intro)
            session.turns.append(turn)
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
}

enum AgentError: Error {
    case noAPIAccess
    case invalidContext
}