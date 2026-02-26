import SwiftUI

struct TopNavigationBar: View {
    var body: some View {
        GeometryReader { proxy in
            let availableWidth = max(proxy.size.width - 48, 320)
            let scale = min(1.0, max(0.58, availableWidth / 980))
            let logoWidth = max(96, 210 * scale)

            HStack(alignment: .center) {
                Text("SIGNAL")
                    .font(SignalFonts.interDisplay(size: 18 * scale, weight: .semibold))
                    .tracking(1.6 * scale)
                    .foregroundStyle(Color.signalInk)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(width: logoWidth, height: 18 * scale, alignment: .leading)

                Spacer()
            }
            .frame(maxWidth: 1280)
            .padding(.horizontal, 24)
        }
        .frame(height: 44)
    }
}
