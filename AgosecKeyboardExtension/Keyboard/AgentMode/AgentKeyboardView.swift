import SwiftUI
import UIKit
import Photos
import KeyboardKit
import SharedCore
import Networking
import OCR
import UIComponents

struct AgentKeyboardView: View {
    let onClose: () -> Void
    let textDocumentProxy: UITextDocumentProxy
    let keyboardState: Keyboard.State?

    @StateObject private var sessionManager = AgentSessionManager()
    @State private var currentStep: AgentStep = .introChoice
    @State private var isLoading = false
    @State private var loadingMessage = ""
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
        .background(agentBackground)
        .loadingOverlay(isPresented: isLoading, message: loadingMessage)
        .toastOverlay(toastManager: toastManager)
    }

    @ViewBuilder
    private var agentBackground: some View {
        switch currentStep {
        case .introChoice:
            Color.clear
        case .chat:
            Color.clear
        }
    }

    private var headerView: some View {
        ZStack {
            if case .chat = currentStep {
                Text("Agent")
                    .font(.system(size: 18, weight: .semibold, design: .default))
                    .foregroundColor(Color.white.opacity(0.85))
            }

            // Left button
            HStack {
                Button(
                    action: { onClose() },
                    label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.black.opacity(0.85))
                            .frame(width: 52, height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.12, green: 0.28, blue: 0.6).opacity(0.18),
                                                Color(red: 0.45, green: 0.2, blue: 0.6).opacity(0.18)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.black.opacity(0.35), lineWidth: 1.5)
                                    )
                            )
                            .background(
                                Color.black.opacity(0.001)
                            )
                            .contentShape(Rectangle())
                    }
                )
                .buttonStyle(PlainButtonStyle())

                Spacer()
            }
        }
        .padding(.horizontal, 8)
        .padding(.leading, 6)
        .padding(.top, 12)
        .frame(height: 72)
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
                    }
                )
                .environmentObject(toastManager)
            case .chat(let session):
                AgentChatView(
                    session: session,
                    textDocumentProxy: textDocumentProxy,
                    keyboardState: keyboardState,
                    onNewSession: {
                        currentStep = .introChoice
                    }
                )
                .id(session.sessionId)
                .environmentObject(toastManager)
            }
        }
    }

    private func handleIntroChoice(_ choice: IntroChoice) {
        isLoading = true

        switch choice {
        case .useAndDeleteScreenshots:
            loadingMessage = "Processing screenshots..."
        case .useScreenshots:
            loadingMessage = "Processing screenshots..."
        case .continueWithoutContext:
            loadingMessage = "Starting conversation..."
        }

        Task {
            do {
                print("choice: \(choice)")
                let session = try await sessionManager.initializeSession(choice: choice)
                await MainActor.run {
                    isLoading = false
                    currentStep = .chat(session: session)
                }
            } catch {
                let message = ErrorMapper.userFriendlyMessage(from: error)
                let shouldRetry = ErrorMapper.shouldShowRetry(for: error)

                await MainActor.run {
                    isLoading = false
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
        // Use shared provider to get appropriate service (mock or real)
        self.chatAPI = ChatAPIProvider.makeChatAPI(sessionId: nil)
        // Use REAL OCR service in mock mode so user can see actual extracted text
        self.ocrService = OCRService()
    }

    func initializeSession(choice: IntroChoice) async throws -> ChatSession {
        var session = ChatSession()
        print("initializeSession: \(choice)")
        switch choice {
        case .useAndDeleteScreenshots(let images, let assetIdentifiers):
            try await applyScreenshotContext(
                images,
                assetIdentifiers: assetIdentifiers,
                to: &session,
                deleteAfterProcessing: true
            )
        case .useScreenshots(let images):
            try await applyScreenshotContext(
                images,
                assetIdentifiers: [],
                to: &session,
                deleteAfterProcessing: false
            )
        case .continueWithoutContext:
            try await appendIntroTurn(to: &session)
        }

        return session
    }

    private func applyScreenshotContext(
        _ images: [UIImage],
        assetIdentifiers: [String],
        to session: inout ChatSession,
        deleteAfterProcessing: Bool
    ) async throws {
        FileLogger.shared.log(
            "Apply screenshot context. images=\(images.count) assets=\(assetIdentifiers.count) delete=\(deleteAfterProcessing)",
            level: .info
        )
        guard !images.isEmpty else {
            FileLogger.shared.log("Invalid context: no images provided", level: .error)
            throw AgentError.invalidContext
        }

        FileLogger.shared.log("Starting OCR extraction", level: .info)
        let context = try await extractContext(from: images)
        FileLogger.shared.log("OCR extraction complete", level: .info)
        try await appendContextTurn(context, to: &session)

        if deleteAfterProcessing, !assetIdentifiers.isEmpty {
            Task.detached(priority: .background) { [weak self] in
                await self?.deletePhotos(assetIdentifiers: assetIdentifiers)
            }
        }
    }

    private func appendContextTurn(_ context: ContextDoc, to session: inout ChatSession) async throws {
        session.context = context

        if BuildMode.isMockBackend {
            FileLogger.shared.log("Mock backend: append OCR turn", level: .debug)
            appendMockOCRTurn(context, to: &session)
            return
        }

        FileLogger.shared.log("Fetching summary from API", level: .info)
        let summary = try await fetchSummary(session: session, context: context)
        FileLogger.shared.log("Summary received", level: .info)
        appendAssistantTurn(summary, to: &session)
    }

    private func appendMockOCRTurn(_ context: ContextDoc, to session: inout ChatSession) {
        let extractedText = context.rawText
        let displayText = """
        📸 **OCR Extracted Text:**

        \(extractedText)

        ---
        *This is the text extracted from your screenshots. In production mode,
        this would be sent to the AI for context.*
        """
        appendAssistantTurn(displayText, to: &session)
    }

    private func appendIntroTurn(to session: inout ChatSession) async throws {
        if BuildMode.isMockBackend {
            FileLogger.shared.log("Mock backend: append intro turn", level: .debug)
            let mockIntro = "Hi! I'm your AI assistant. I can help you write messages, answer questions," +
                " and provide context-aware responses. What can I help you with today?"
            appendAssistantTurn(mockIntro, to: &session)
            return
        }

        FileLogger.shared.log("Fetching intro from API", level: .info)
        let intro = try await fetchIntro(session: session)
        FileLogger.shared.log("Intro received", level: .info)
        appendAssistantTurn(intro, to: &session)
    }

    private func appendAssistantTurn(_ text: String, to session: inout ChatSession) {
        let turn = ChatTurn(role: .assistant, text: text)
        session.turns.append(turn)
    }

    private func extractContext(from images: [UIImage]) async throws -> ContextDoc {
        do {
            FileLogger.shared.log("Downscaling images for OCR", level: .debug)
            let resizedImages = downscaleImagesForOCR(images)
            let context = try await ocrService.extractText(from: resizedImages)
            return context
        } catch {
            FileLogger.shared.log("OCR extraction failed: \(error)", level: .error)
            throw error
        }
    }

    private func downscaleImagesForOCR(_ images: [UIImage], maxDimension: CGFloat = 1280) -> [UIImage] {
        images.map { image in
            let size = image.size
            let maxSide = max(size.width, size.height)
            guard maxSide > maxDimension, maxSide > 0 else { return image }

            let scale = maxDimension / maxSide
            let targetSize = CGSize(width: size.width * scale, height: size.height * scale)
            let format = UIGraphicsImageRendererFormat.default()
            format.scale = 1

            return UIGraphicsImageRenderer(size: targetSize, format: format).image { _ in
                image.draw(in: CGRect(origin: .zero, size: targetSize))
            }
        }
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
            return
        }

        // Fetch PHAsset objects from identifiers
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: assetIdentifiers, options: nil)
        guard fetchResult.count > 0 else {
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
        } catch {
            // Don't throw - deletion failure shouldn't block the session
        }
    }
}

enum AgentError: Error, UserPresentableError {
    case noAPIAccess
    case invalidContext

    var userMessage: String {
        switch self {
        case .noAPIAccess:
            return "API access is not available. This usually means you need to authenticate or have an active " +
                "subscription. Please check your account status in the main app, or sign in again."
        case .invalidContext:
            return "Invalid context provided. The context data may be corrupted or in an unsupported format. " +
                "Please try again with a fresh session or different screenshots."
        }
    }

    var isRetryable: Bool {
        switch self {
        case .noAPIAccess:
            return false
        case .invalidContext:
            return true
        }
    }
}
