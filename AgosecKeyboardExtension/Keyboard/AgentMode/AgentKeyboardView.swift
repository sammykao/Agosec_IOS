import SwiftUI
import UIKit

struct AgentKeyboardView: View {
    let onClose: () -> Void
    let textDocumentProxy: UITextDocumentProxy
    
    @StateObject private var sessionManager = AgentSessionManager()
    @State private var currentStep: AgentStep = .introChoice
    
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
        switch currentStep {
        case .introChoice:
            AgentIntroView { choice in
                handleIntroChoice(choice)
            }
        case .chat(let session):
            AgentChatView(
                session: session,
                textDocumentProxy: textDocumentProxy,
                onNewSession: {
                    currentStep = .introChoice
                }
            )
        }
    }
    
    private func handleIntroChoice(_ choice: IntroChoice) {
        Task {
            do {
                let session = try await sessionManager.initializeSession(choice: choice)
                await MainActor.run {
                    currentStep = .chat(session: session)
                }
            } catch {
                print("Failed to initialize session: \(error)")
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
    
    init() {
        if let accessToken: String = AppGroupStorage.shared.get(String.self, for: "access_token") {
            self.chatAPI = ChatAPI(
                client: APIClient(baseURL: Config.shared.backendBaseUrl),
                accessToken: accessToken
            )
        } else {
            self.chatAPI = nil
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
        let ocrService = OCRService()
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