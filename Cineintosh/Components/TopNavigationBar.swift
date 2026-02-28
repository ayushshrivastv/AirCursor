import SwiftUI

struct TopNavigationBar: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("CINEINTOSH.")
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Spacer(minLength: 8)

                Text("RETRO BUILD R2")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.95))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.cineintoshRetroTitleBlue)

            HStack(spacing: 8) {
                Text("offline vision telemetry")
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .foregroundStyle(Color.cineintoshInk)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                Spacer(minLength: 8)

                Circle()
                    .fill(Color.green.opacity(0.9))
                    .frame(width: 7, height: 7)

                Text("READY")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.cineintoshInk)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Color.cineintoshRetroSurface)
        }
        .frame(maxWidth: 1280)
        .padding(.horizontal, 24)
        .cineintoshRetroBevel()
        .frame(height: 62)
    }
}
