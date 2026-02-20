import SwiftUI

struct SignalTitleOverlay: View {
    var body: some View {
        let title = Text("SIGNAL")
            .font(SignalFonts.antonSC(size: 260))
            .tracking(-2)
            .lineLimit(1)
            .minimumScaleFactor(0.2)

        title
            .foregroundStyle(.clear)
            .overlay {
                LinearGradient(
                    stops: [
                        .init(color: .white, location: 0.0),
                        .init(color: .white, location: 0.5),
                        .init(color: .white.opacity(0), location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .mask(title)
            }
    }
}
