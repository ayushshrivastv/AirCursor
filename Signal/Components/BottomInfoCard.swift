import SwiftUI

struct BottomInfoCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("BROWSE THOUSANDS OF VERIFIED LISTINGS, CONNECT WITH TOP AGENTS.")
                .font(SignalFonts.interDisplay(size: 16, weight: .regular))
                .foregroundStyle(.white)
                .lineSpacing(3)

            Button(action: {}) {
                Text("CONTACT US")
                    .font(SignalFonts.manrope(size: 16, weight: .semibold))
                    .foregroundStyle(Color.signalInk)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(Color.white, in: Capsule())
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)
        }
        .frame(width: 243, alignment: .leading)
    }
}
