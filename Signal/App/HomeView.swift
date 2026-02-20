import SwiftUI

struct HomeView: View {
    @AppStorage("hasSeenSignalProjectIntro") private var hasSeenSignalProjectIntro = false
    @State private var isSidebarOpen = true
    @State private var showProjectIntro = false
    private let openSidebarWidth: CGFloat = 236
    private let closedSidebarWidth: CGFloat = 68

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                HStack(spacing: 0) {
                    SidebarView(isOpen: $isSidebarOpen)
                        .frame(width: isSidebarOpen ? openSidebarWidth : closedSidebarWidth)

                    LandingContentView(
                        isSidebarOpen: $isSidebarOpen,
                        onStartTap: {
                            hasSeenSignalProjectIntro = true
                            withAnimation(.easeOut(duration: 0.2)) {
                                showProjectIntro = false
                            }
                        },
                        onLearnTap: {
                            withAnimation(.easeOut(duration: 0.2)) {
                                showProjectIntro = true
                            }
                        }
                    )
                        .frame(width: proxy.size.width - (isSidebarOpen ? openSidebarWidth : closedSidebarWidth))
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .background(Color.signalWhite)
                .clipped()
                .animation(.spring(response: 0.35, dampingFraction: 0.86), value: isSidebarOpen)

                if showProjectIntro {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .transition(.opacity)

                    ProjectIntroPopup {
                        hasSeenSignalProjectIntro = true
                        withAnimation(.easeOut(duration: 0.2)) {
                            showProjectIntro = false
                        }
                    }
                    .frame(width: min(560, proxy.size.width - 48))
                    .padding(.horizontal, 24)
                    .transition(.scale(scale: 0.95).combined(with: .opacity))
                    .zIndex(2)
                }
            }
            .onAppear {
                guard !hasSeenSignalProjectIntro else { return }
                withAnimation(.easeOut(duration: 0.2)) {
                    showProjectIntro = true
                }
            }
        }
    }
}
