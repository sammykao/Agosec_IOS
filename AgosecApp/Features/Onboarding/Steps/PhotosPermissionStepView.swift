import SwiftUI
import UIKit
import PhotosUI
import UIComponents

struct PhotosPermissionStepView: View {
    @State private var photosStatus: PHAuthorizationStatus = .notDetermined
    let onNext: () -> Void

    var body: some View {
        OnboardingStepScaffold(
            isScrollable: true,
            topSpacing: { geometry in
                ResponsiveSystem.isShortScreen
                    ? max(geometry.size.height * 0.10, 50)
                    : max(geometry.size.height * 0.12, 60)
            },
            header: { geometry, state in
                let iconSize = ResponsiveSystem.value(
                    extraSmall: 75,
                    small: 82,
                    standard: min(geometry.size.width * 0.22, 90)
                )
                let ringBaseSize = ResponsiveSystem.value(
                    extraSmall: 85,
                    small: 92,
                    standard: min(geometry.size.width * 0.25, 100)
                )

                return ZStack {
                    ForEach(0..<2) { index in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.green.opacity(0.4 - Double(index) * 0.2),
                                        Color.green.opacity(0.15 - Double(index) * 0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: ResponsiveSystem.value(extraSmall: 1.5, small: 1.5, standard: 2)
                            )
                            .frame(
                                width: ringBaseSize + CGFloat(index) * 16,
                                height: ringBaseSize + CGFloat(index) * 16
                            )
                            .scaleEffect(1.0 + CGFloat(index) * 0.1)
                            .opacity(state.headerOpacity * (1.0 - Double(index) * 0.3))
                    }

                    let photoStackSize = min(geometry.size.width * 0.18, 75)
                    ForEach(0..<2) { index in
                        RoundedRectangle(cornerRadius: ResponsiveSystem.isSmallScreen ? 10 : 12)
                            .fill(Color.green.opacity(0.12 - Double(index) * 0.04))
                            .frame(
                                width: photoStackSize - CGFloat(index) * 10,
                                height: photoStackSize - CGFloat(index) * 10
                            )
                            .offset(x: CGFloat(index) * 6, y: CGFloat(index) * -6)
                            .rotationEffect(.degrees(Double(index) * -4))
                            .opacity(state.headerOpacity * 0.6)
                    }

                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.green.opacity(0.25),
                                        Color.green.opacity(0.12)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: iconSize, height: iconSize)

                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.green.opacity(0.4),
                                        Color.green.opacity(0.15)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                            .frame(width: iconSize, height: iconSize)

                        Image(systemName: "photo.stack.fill")
                            .font(.system(size: min(geometry.size.width * 0.1, 40), weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.green, Color.green.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
                .scaleEffect(state.headerScale)
                .opacity(state.headerOpacity)
                .padding(.bottom, min(geometry.size.height * 0.03, 24))
            },
            bodyContent: { geometry, _ in
                VStack(spacing: 0) {
                    Text("Photo Access")
                        .font(.system(size: min(geometry.size.width * 0.07, 28), weight: .bold, design: .default))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.white, Color.green],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text("Allow access to screenshots for AI context awareness")
                        .font(.system(size: min(geometry.size.width * 0.043, 17), weight: .regular, design: .default))
                        .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.75))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, geometry.size.width * 0.1)
                        .padding(.top, min(geometry.size.height * 0.015, 12))

                    infoCard(in: geometry)
                        .padding(.top, min(geometry.size.height * 0.03, 24))
                }
            },
            footer: { geometry, _ in
                buttonsForStatus(in: geometry)
                    .padding(.horizontal, geometry.size.width * 0.07)
            },
            onAppear: {
                checkPhotoStatus()
            }
        )
        .onAppBecameActive {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                checkPhotoStatus()
            }
        }
    }

    private func infoCard(in geometry: GeometryProxy) -> some View {
        let iconSize: CGFloat = ResponsiveSystem.value(extraSmall: 17, small: 18, standard: 20)
        let titleSize: CGFloat = ResponsiveSystem.value(extraSmall: 13, small: 14, standard: 16)
        let descSize: CGFloat = ResponsiveSystem.value(extraSmall: 11, small: 12, standard: 14)
        let spacing: CGFloat = ResponsiveSystem.value(extraSmall: 9, small: 10, standard: 14)

        return VStack(spacing: ResponsiveSystem.value(extraSmall: 10, small: 12, standard: 16)) {
            HStack(spacing: spacing) {
                Image(systemName: "sparkles")
                    .font(.system(size: iconSize, weight: .medium))
                    .foregroundColor(.purple)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Smart Context")
                        .font(.system(size: titleSize, weight: .semibold, design: .default))
                        .foregroundColor(Color(red: 0.9, green: 0.9, blue: 0.95))

                    Text("AI can understand screenshots to help you respond")
                        .font(.system(size: descSize, weight: .regular, design: .default))
                        .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.65))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }

            Divider()
                .background(Color.white.opacity(0.2))

            HStack(spacing: spacing) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: iconSize, weight: .medium))
                    .foregroundColor(.blue)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Required for Full Features")
                        .font(.system(size: titleSize, weight: .semibold, design: .default))
                        .foregroundColor(Color(red: 0.9, green: 0.9, blue: 0.95))

                    Text("Screenshots are processed locally and deleted immediately")
                        .font(.system(size: descSize, weight: .regular, design: .default))
                        .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.65))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
        }
        .padding(.horizontal, ResponsiveSystem.isSmallScreen ? 16 : 20)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .padding(.horizontal, geometry.size.width * 0.06)
    }

    @ViewBuilder
    private func buttonsForStatus(in geometry: GeometryProxy) -> some View {
        switch photosStatus {
        case .authorized, .limited:
            VStack(spacing: 12) {
                ModernActionButton(
                    title: "Continue",
                    icon: "arrow.right",
                    action: onNext
                )

                Text("Photo access enabled!")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.green)
            }
        case .denied, .restricted:
            VStack(spacing: 12) {
                ModernActionButton(
                    title: "Open Settings",
                    icon: "gear",
                    action: openSettings
                )

                Text("Please enable photo access to continue")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.65))
                    .multilineTextAlignment(.center)
            }
        case .notDetermined:
            ModernActionButton(
                title: "Allow Photo Access",
                icon: "photo.fill",
                action: requestPhotoAccess
            )
        @unknown default:
            ModernActionButton(
                title: "Allow Photo Access",
                icon: "photo.fill",
                action: requestPhotoAccess
            )
        }
    }

    private func requestPhotoAccess() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    photosStatus = status
                }
            }
        }
    }

    private func checkPhotoStatus() {
        photosStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
