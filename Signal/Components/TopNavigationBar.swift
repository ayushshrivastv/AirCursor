import SwiftUI

struct TopNavigationBar: View {
    let onMenuTap: () -> Void

    private let links = ["SERVICES", "PROJECTS", "ABOUT", "CONTACT US"]

    var body: some View {
        GeometryReader { proxy in
            let availableWidth = max(proxy.size.width - 48, 320)
            let scale = min(1.0, max(0.58, availableWidth / 980))
            let logoWidth = max(96, 163 * scale)
            let sideSpacer = max(10, 48 * scale)
            let linkSpacing = max(12, 49 * scale)
            let linkFontSize = max(10, 16 * scale)
            let hamburgerWidth = max(34, 60 * scale)
            let hamburgerGap = max(5, 10 * scale)
            let hamburgerStroke = max(1, 1.5 * scale)

            HStack(alignment: .center) {
                Text("SIGNAL")
                    .font(SignalFonts.interDisplay(size: 18 * scale, weight: .semibold))
                    .tracking(1.6 * scale)
                    .foregroundStyle(Color.signalInk)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(width: logoWidth, height: 18 * scale, alignment: .leading)

                Spacer(minLength: sideSpacer)

                HStack(spacing: linkSpacing) {
                    ForEach(links, id: \.self) { link in
                        NavigationLabel(text: link, fontSize: linkFontSize)
                    }
                }

                Spacer(minLength: sideSpacer)

                Button(action: onMenuTap) {
                    VStack(spacing: hamburgerGap) {
                        Capsule()
                            .fill(Color.signalInk)
                            .frame(width: hamburgerWidth, height: hamburgerStroke)
                        Capsule()
                            .fill(Color.signalInk)
                            .frame(width: hamburgerWidth, height: hamburgerStroke)
                    }
                    .frame(width: hamburgerWidth, height: 16 * scale)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: 1280)
            .padding(.horizontal, 24)
        }
        .frame(height: 44)
    }
}

private struct NavigationLabel: View {
    let text: String
    let fontSize: CGFloat
    @State private var isHovering = false

    var body: some View {
        Text(text)
            .font(SignalFonts.interDisplay(size: fontSize, weight: .regular))
            .foregroundStyle(Color.signalInk)
            .lineLimit(1)
            .minimumScaleFactor(0.62)
            .allowsTightening(true)
            .opacity(isHovering ? 0.58 : 1)
            .animation(.easeInOut(duration: 0.2), value: isHovering)
            .onHover { hover in
                isHovering = hover
            }
    }
}
