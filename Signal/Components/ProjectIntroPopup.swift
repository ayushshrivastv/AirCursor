import SwiftUI

struct ProjectIntroPopup: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("WELCOME TO SIGNAL")
                    .font(SignalFonts.interDisplay(size: 12, weight: .medium))
                    .tracking(1.4)
                    .foregroundStyle(Color.signalInk.opacity(0.62))

                Spacer()
            }

            Text("Touchless typing, designed for precision.")
                .font(SignalFonts.interDisplay(size: 34, weight: .semibold))
                .foregroundStyle(Color.signalInk)
                .lineLimit(2)
                .minimumScaleFactor(0.7)

            Text("Signal uses front-camera hand tracking to map fingertip motion to an on-screen keyboard. Hover to target a key, air tap to confirm, and type without touching the screen.")
                .font(SignalFonts.interDisplay(size: 15, weight: .regular))
                .foregroundStyle(Color.signalInk.opacity(0.78))
                .lineSpacing(4)

            HStack(spacing: 8) {
                introChip("Machine Learning")
                introChip("Track")
                introChip("Hover")
                introChip("Air Tap")
                introChip("Type")
            }
            .padding(.top, 2)

            HStack {
                Spacer()
                Button(action: onContinue) {
                    Text("CONTINUE")
                        .font(SignalFonts.manrope(size: 14, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .padding(.vertical, 11)
                        .padding(.horizontal, 20)
                        .background(Color.signalInk, in: Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 6)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.signalInk.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 24, x: 0, y: 16)
    }

    private func introChip(_ title: String) -> some View {
        Text(title.uppercased())
            .font(SignalFonts.interDisplay(size: 11, weight: .medium))
            .foregroundStyle(Color.signalInk.opacity(0.78))
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background(
                Capsule()
                    .fill(Color.signalInk.opacity(0.08))
            )
    }
}
