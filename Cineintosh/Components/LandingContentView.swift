import SwiftUI

struct LandingContentView: View {
    let onStartTap: () -> Void
    let onLearnTap: () -> Void
    private static let backgroundImage: NSImage? = {
        guard let url = Bundle.main.url(forResource: "CineintoshBackground", withExtension: "png") else {
            return nil
        }
        return NSImage(contentsOf: url)
    }()

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                if let backgroundImage = Self.backgroundImage {
                    Image(nsImage: backgroundImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                } else {
                    Image("CineintoshBackground")
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                }

                Color.black.opacity(0.12)

                CineintoshTitleOverlay()
                    .frame(maxWidth: min(proxy.size.width - 64, 1600))
                    .position(x: proxy.size.width / 2, y: 149 + 130)
                    .zIndex(1)

                TopNavigationBar()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.top, 40)
                .zIndex(10)

                BottomInfoCard()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .padding(.leading, 65)
                    .padding(.bottom, 150)
                    .zIndex(10)

                TagPillsView(tags: ["Verified Listing", "New on Market", "Just Listed", "Prime Location"])
                    .frame(width: 282)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(.trailing, 100)
                    .padding(.bottom, 70)
                    .zIndex(10)

                let actionScale = min(1.22, max(0.95, proxy.size.width / 860))
                let actionY = max(420, min(proxy.size.height - 130, proxy.size.height * 0.80))

                CenterActionBar(onStartTap: onStartTap, onLearnTap: onLearnTap)
                    .scaleEffect(actionScale)
                    .position(x: proxy.size.width / 2, y: actionY)
                    .zIndex(60)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.cineintoshWhite)
            .clipped()
        }
    }
}

private struct CenterActionBar: View {
    let onStartTap: () -> Void
    let onLearnTap: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button(action: onStartTap) {
                HStack(spacing: 9) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .bold))
                    Text("START")
                        .font(CineintoshFonts.manrope(size: 16, weight: .semibold))
                }
                .foregroundStyle(Color.cineintoshInk)
                .padding(.vertical, 14)
                .padding(.horizontal, 22)
                .background(
                    Capsule()
                        .fill(Color.white)
                        .overlay(Capsule().stroke(Color.cineintoshInk.opacity(0.14), lineWidth: 1))
                )
                .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 7)
            }
            .buttonStyle(.plain)

            Button(action: onLearnTap) {
                HStack(spacing: 9) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 13, weight: .semibold))
                    Text("LEARN")
                        .font(CineintoshFonts.interDisplay(size: 15, weight: .medium))
                }
                .foregroundStyle(Color.cineintoshInk)
                .padding(.vertical, 13)
                .padding(.horizontal, 20)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.95))
                        .overlay(Capsule().stroke(Color.cineintoshInk.opacity(0.14), lineWidth: 1))
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.28))
                .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
        )
        .shadow(color: Color.black.opacity(0.28), radius: 16, x: 0, y: 10)
    }
}
