import SwiftUI

private struct SidebarItem: Identifiable {
    let title: String
    let symbol: String
    let badge: String?

    var id: String { title }
}

struct SidebarView: View {
    @Binding var isOpen: Bool
    @State private var selectedItem = "Dashboard"

    private let primaryItems: [SidebarItem] = [
        .init(title: "Dashboard", symbol: "square.grid.2x2", badge: nil),
        .init(title: "Studio", symbol: "wand.and.stars", badge: nil),
        .init(title: "Campaigns", symbol: "megaphone", badge: "3"),
        .init(title: "Analytics", symbol: "chart.line.uptrend.xyaxis", badge: nil),
        .init(title: "Settings", symbol: "slider.horizontal.3", badge: nil)
    ]

    private let workspaceItems: [SidebarItem] = [
        .init(title: "Drafts", symbol: "doc.text", badge: "2"),
        .init(title: "Templates", symbol: "square.stack.3d.up", badge: nil)
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.white.opacity(0.96), Color.white.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )

            if isOpen {
                expandedSidebar
            } else {
                compactSidebar
            }
        }
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(Color.signalInk.opacity(0.1))
                .frame(width: 1)
        }
    }

    private var expandedSidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Text("SIGNAL")
                    .font(SignalFonts.interDisplay(size: 18, weight: .semibold))
                    .tracking(1.8)
                    .foregroundStyle(Color.signalInk)

                Spacer()
                toggleButton
            }
            .padding(.top, 2)

            Text("CREATIVE CONTROL PANEL")
                .font(SignalFonts.interDisplay(size: 11, weight: .medium))
                .tracking(1.1)
                .foregroundStyle(Color.signalInk.opacity(0.48))
                .padding(.top, 12)

            Divider()
                .padding(.top, 14)
                .padding(.bottom, 12)

            section(title: "Navigation", items: primaryItems)
                .padding(.bottom, 8)

            section(title: "Workspace", items: workspaceItems)

            Spacer(minLength: 16)

            VStack(alignment: .leading, spacing: 8) {
                Text("Creative workstation")
                    .font(SignalFonts.interDisplay(size: 12, weight: .medium))
                    .foregroundStyle(Color.signalInk.opacity(0.9))

                Text("2 drafts pending review")
                    .font(SignalFonts.interDisplay(size: 11, weight: .regular))
                    .foregroundStyle(Color.signalInk.opacity(0.6))
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.72))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.signalInk.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 16)
    }

    private var compactSidebar: some View {
        VStack(spacing: 10) {
            toggleButton
                .padding(.top, 6)

            ForEach(primaryItems) { item in
                Button {
                    selectedItem = item.title
                } label: {
                    Image(systemName: item.symbol)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(selectedItem == item.title ? Color.white : Color.signalInk.opacity(0.8))
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(selectedItem == item.title ? Color.signalInk : Color.signalInk.opacity(0.08))
                        )
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
    }

    private var toggleButton: some View {
        Button(action: { isOpen.toggle() }) {
            Image(systemName: isOpen ? "sidebar.left" : "sidebar.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.signalInk)
                .frame(width: 32, height: 32)
                .background(Color.white.opacity(0.9), in: Circle())
                .overlay(Circle().stroke(Color.signalInk.opacity(0.16), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func section(title: String, items: [SidebarItem]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(SignalFonts.interDisplay(size: 10, weight: .medium))
                .tracking(1.2)
                .foregroundStyle(Color.signalInk.opacity(0.45))
                .padding(.bottom, 4)

            ForEach(items) { item in
                sidebarRow(for: item)
            }
        }
    }

    private func sidebarRow(for item: SidebarItem) -> some View {
        let isSelected = selectedItem == item.title

        return Button {
            selectedItem = item.title
        } label: {
            HStack(spacing: 10) {
                Image(systemName: item.symbol)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.white : Color.signalInk.opacity(0.8))
                    .frame(width: 24)

                Text(item.title.uppercased())
                    .font(SignalFonts.interDisplay(size: 13, weight: .medium))
                    .foregroundStyle(isSelected ? Color.white : Color.signalInk.opacity(0.78))

                Spacer(minLength: 8)

                if let badge = item.badge {
                    Text(badge)
                        .font(SignalFonts.interDisplay(size: 10, weight: .semibold))
                        .foregroundStyle(isSelected ? Color.signalInk : Color.white)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 6)
                        .background(
                            Capsule()
                                .fill(isSelected ? Color.white.opacity(0.9) : Color.signalInk.opacity(0.62))
                        )
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isSelected ? Color.signalInk : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}
