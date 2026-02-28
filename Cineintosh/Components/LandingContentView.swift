import AppKit
import SwiftUI

private extension Color {
    static let mpLight   = Color(red: 0.898, green: 0.894, blue: 0.882)
    static let mpMid     = Color(red: 0.800, green: 0.796, blue: 0.784)
    static let mpBase    = Color(red: 0.725, green: 0.718, blue: 0.706)
    static let mpDark    = Color(red: 0.514, green: 0.506, blue: 0.494)
    static let mpDeep    = Color(red: 0.310, green: 0.302, blue: 0.294)
    static let mpPaper   = Color(red: 0.961, green: 0.961, blue: 0.953)
    static let mpInk     = Color(red: 0.047, green: 0.039, blue: 0.035)
    static let sysBlueDk = Color(red: 0.043, green: 0.090, blue: 0.459)
    static let sysBlueLt = Color(red: 0.192, green: 0.290, blue: 0.722)
    static let sysGreen  = Color(red: 0.180, green: 0.800, blue: 0.282)
}

private struct MacBevelModifier: ViewModifier {
    enum Style { case raised, sunken, window }
    let style: Style

    func body(content: Content) -> some View {
        content.overlay(bevelOverlay)
    }

    @ViewBuilder
    private var bevelOverlay: some View {
        switch style {
        case .raised:
            ZStack {
                edgeRect(.top,      Color.mpLight, 2, 0)
                edgeRect(.leading,  Color.mpLight, 2, 0)
                edgeRect(.bottom,   Color.mpDeep,  2, 0)
                edgeRect(.trailing, Color.mpDeep,  2, 0)
                edgeRect(.top,      Color.mpMid,   1, 2)
                edgeRect(.leading,  Color.mpMid,   1, 2)
                edgeRect(.bottom,   Color.mpDark,  1, 2)
                edgeRect(.trailing, Color.mpDark,  1, 2)
            }
        case .sunken:
            ZStack {
                edgeRect(.top,      Color.mpDeep,  1, 0)
                edgeRect(.leading,  Color.mpDeep,  1, 0)
                edgeRect(.bottom,   Color.mpLight, 1, 0)
                edgeRect(.trailing, Color.mpLight, 1, 0)
                edgeRect(.top,      Color.mpDark,  1, 1)
                edgeRect(.leading,  Color.mpDark,  1, 1)
                edgeRect(.bottom,   Color.mpBase,  1, 1)
                edgeRect(.trailing, Color.mpBase,  1, 1)
            }
        case .window:
            ZStack {
                edgeRect(.top,      Color.mpLight, 2, 0)
                edgeRect(.leading,  Color.mpLight, 2, 0)
                edgeRect(.bottom,   Color.mpDeep,  2, 0)
                edgeRect(.trailing, Color.mpDeep,  2, 0)
                edgeRect(.top,      Color.mpMid,   2, 2)
                edgeRect(.leading,  Color.mpMid,   2, 2)
                edgeRect(.bottom,   Color.mpDark,  2, 2)
                edgeRect(.trailing, Color.mpDark,  2, 2)
                edgeRect(.top,      Color.mpBase,  1, 4)
                edgeRect(.leading,  Color.mpBase,  1, 4)
                edgeRect(.bottom,   Color.mpDeep,  1, 4)
                edgeRect(.trailing, Color.mpDeep,  1, 4)
            }
        }
    }

    private func edgeRect(_ edge: Edge, _ color: Color, _ thickness: CGFloat, _ inset: CGFloat) -> some View {
        Group {
            switch edge {
            case .top:
                VStack { color.frame(height: thickness); Spacer() }.padding(inset)
            case .bottom:
                VStack { Spacer(); color.frame(height: thickness) }.padding(inset)
            case .leading:
                HStack { color.frame(width: thickness); Spacer() }.padding(inset)
            case .trailing:
                HStack { Spacer(); color.frame(width: thickness) }.padding(inset)
            @unknown default:
                EmptyView()
            }
        }
    }
}

extension View {
    fileprivate func macBevel(_ style: MacBevelModifier.Style = .raised) -> some View {
        modifier(MacBevelModifier(style: style))
    }
}

private struct TitleStripes: View {
    var active: Bool = true

    var body: some View {
        Canvas { ctx, size in
            let bg     = active ? Color.mpDeep.opacity(0.88)  : Color.mpBase.opacity(0.75)
            let stripe = active ? Color.white.opacity(0.55)   : Color.mpLight.opacity(0.65)
            ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .color(bg))
            var y: CGFloat = 0
            while y < size.height {
                ctx.fill(Path(CGRect(x: 0, y: y, width: size.width, height: 2)),
                         with: .color(stripe))
                y += 4
            }
        }
    }
}

private struct RainbowApple: View {
    let fontSize: CGFloat

    private static let stops: [Gradient.Stop] = [
        .init(color: Color(red: 0.443, green: 0.745, blue: 0.247), location: 0.00),
        .init(color: Color(red: 0.443, green: 0.745, blue: 0.247), location: 0.17),
        .init(color: Color(red: 0.973, green: 0.855, blue: 0.071), location: 0.17),
        .init(color: Color(red: 0.973, green: 0.855, blue: 0.071), location: 0.34),
        .init(color: Color(red: 0.992, green: 0.561, blue: 0.027), location: 0.34),
        .init(color: Color(red: 0.992, green: 0.561, blue: 0.027), location: 0.50),
        .init(color: Color(red: 0.929, green: 0.173, blue: 0.165), location: 0.50),
        .init(color: Color(red: 0.929, green: 0.173, blue: 0.165), location: 0.67),
        .init(color: Color(red: 0.686, green: 0.243, blue: 0.647), location: 0.67),
        .init(color: Color(red: 0.686, green: 0.243, blue: 0.647), location: 0.84),
        .init(color: Color(red: 0.224, green: 0.463, blue: 0.839), location: 0.84),
        .init(color: Color(red: 0.224, green: 0.463, blue: 0.839), location: 1.00),
    ]

    var body: some View {
        Image(systemName: "applelogo")
            .font(.system(size: fontSize, weight: .bold))
            .foregroundStyle(
                LinearGradient(stops: Self.stops, startPoint: .top, endPoint: .bottom)
            )
    }
}

private struct Scanlines: View {
    var opacity: Double = 0.06

    var body: some View {
        Canvas { ctx, size in
            var y: CGFloat = 0
            while y < size.height {
                ctx.stroke(
                    Path { p in p.move(to: .init(x: 0, y: y)); p.addLine(to: .init(x: size.width, y: y)) },
                    with: .color(.black.opacity(opacity)), lineWidth: 0.7)
                y += 3
            }
        }
        .blendMode(.multiply)
        .allowsHitTesting(false)
    }
}

private struct WinBox: View {
    var isClose: Bool = true

    var body: some View {
        ZStack {
            Color.mpBase
            if isClose {
                Group {
                    Rectangle().frame(width: 7, height: 1.5).rotationEffect(.degrees(45))
                    Rectangle().frame(width: 7, height: 1.5).rotationEffect(.degrees(-45))
                }.foregroundStyle(Color.mpInk.opacity(0.82))
            } else {
                Rectangle().fill(Color.mpInk.opacity(0.68)).frame(width: 6, height: 6)
            }
        }
        .frame(width: 15, height: 15)
        .macBevel(.raised)
    }
}

private struct DotRule: View {
    var body: some View {
        Canvas { ctx, size in
            var x: CGFloat = 1.5
            while x < size.width {
                ctx.fill(
                    Path(CGRect(x: x, y: (size.height - 1.5) / 2, width: 1.5, height: 1.5)),
                    with: .color(Color.mpDark.opacity(0.50)))
                x += 5
            }
        }
        .frame(height: 4)
    }
}

private struct InfoCard: View {
    let title: String
    let value: String
    let symbol: String
    let m: LandingLayoutMetrics

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                TitleStripes(active: true)
                HStack(spacing: 5) {
                    Image(systemName: symbol)
                        .font(.system(size: m.cardTitleFont, weight: .bold))
                        .foregroundStyle(.white.opacity(0.9))
                    Text(title)
                        .font(.system(size: m.cardTitleFont, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    WinBox(isClose: true).scaleEffect(0.80)
                }
                .padding(.horizontal, 7)
            }
            .frame(height: m.cardTitleH)

            HStack(alignment: .top, spacing: 8) {
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.sysBlueDk)
                    .frame(width: 3)
                Text(value)
                    .font(.system(size: m.cardBodyFont, weight: .regular, design: .monospaced))
                    .foregroundStyle(Color.mpInk.opacity(0.88))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
            }
            .padding(9)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.mpPaper)
        }
        .background(Color.mpBase)
        .macBevel(.raised)
    }
}

struct LandingContentView: View {
    let onStartTap: () -> Void
    let onLearnTap: () -> Void

    private static let backgroundImage: NSImage? = {
        let candidates = [
            Bundle.main.url(forResource: "CineintoshBackground", withExtension: "png", subdirectory: "Images"),
            Bundle.main.url(forResource: "CineintoshBackground", withExtension: "png")
        ].compactMap { $0 }
        for url in candidates {
            if let img = NSImage(contentsOf: url) { return img }
        }
        return nil
    }()

    private var targetLabels: [String] { CineintoshObjectClasses.filter }
    private var targetClassText: String { targetLabels.joined(separator: ", ") }

    var body: some View {
        GeometryReader { geo in
            let m = LandingLayoutMetrics(size: geo.size)
            ZStack {
                bgLayer(size: geo.size)
                Scanlines(opacity: 0.065)
                cornerBranding(m: m)
                macWindow(m: m)
                    .frame(width: m.windowW, height: m.windowH)
                    .position(x: geo.size.width * 0.5, y: m.windowCY(total: geo.size))
                    .shadow(color: .black.opacity(0.65), radius: 30, x: 0, y: 16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .clipped()
        }
    }

    private func bgLayer(size: CGSize) -> some View {
        Group {
            if let img = Self.backgroundImage {
                Image(nsImage: img).resizable().scaledToFill()
            } else {
                Image("CineintoshBackground").resizable().scaledToFill()
            }
        }
        .frame(width: size.width, height: size.height)
        .clipped()
        .overlay(
            RadialGradient(
                colors: [.clear, .black.opacity(0.52)],
                center: .center,
                startRadius: size.width * 0.20,
                endRadius: size.width * 0.72
            )
        )
    }

    private func cornerBranding(m: LandingLayoutMetrics) -> some View {
        VStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    RainbowApple(fontSize: m.brandAppleSz)
                    Text("CINEINTOSH™")
                        .font(.system(size: m.brandLabelSz, weight: .black, design: .monospaced))
                        .foregroundStyle(Color.white.opacity(0.90))
                        .shadow(color: .black.opacity(0.75), radius: 0, x: 1, y: 1)
                }
                Spacer(minLength: 0)
                VStack(alignment: .trailing, spacing: 2) {
                    Text("System 1.0")
                        .font(.system(size: m.brandLabelSz + 1, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.80))
                        .shadow(color: .black.opacity(0.6), radius: 0, x: 1, y: 1)
                    Text("© 1984 Cineintosh Inc.")
                        .font(.system(size: m.brandLabelSz, weight: .regular, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.55))
                        .shadow(color: .black.opacity(0.5), radius: 0, x: 1, y: 1)
                }
            }
            .padding(.horizontal, m.outerPad)
            .padding(.top, m.outerPad)
            Spacer(minLength: 0)
        }
    }

    private func macWindow(m: LandingLayoutMetrics) -> some View {
        VStack(spacing: 0) {
            titleBar(m: m)
            menuBar(m: m)
            contentArea(m: m)
            statusBar(m: m)
        }
        .background(Color.mpBase)
        .macBevel(.window)
        .overlay(Rectangle().stroke(Color.mpDeep, lineWidth: 1))
    }

    private func titleBar(m: LandingLayoutMetrics) -> some View {
        ZStack {
            TitleStripes(active: true)
            HStack(spacing: 7) {
                WinBox(isClose: true)
                Spacer(minLength: 0)
                HStack(spacing: 6) {
                    Image(systemName: "applelogo")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white.opacity(0.92))
                    Text("✦ Cineintosh Workstation")
                        .font(.system(size: m.titleBarFont, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }
                Spacer(minLength: 0)
                WinBox(isClose: false)
            }
            .padding(.horizontal, 9)
        }
        .frame(height: m.titleBarH)
    }

    private func menuBar(m: LandingLayoutMetrics) -> some View {
        HStack(spacing: 0) {
            ForEach(["  File", "  Edit", "  View", "  Tools", "  Help"], id: \.self) { label in
                Text(label)
                    .font(.system(size: m.menuFont, weight: .regular))
                    .foregroundStyle(Color.mpInk.opacity(0.88))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 4)
            }
            Spacer(minLength: 0)
            HStack(spacing: 5) {
                Circle().fill(Color.sysGreen).frame(width: 7, height: 7)
                    .overlay(Circle().stroke(Color.mpDeep.opacity(0.5), lineWidth: 0.5))
                Text("LOCAL MODE")
                    .font(.system(size: m.menuFont - 1, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.mpInk.opacity(0.78))
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 3)
            .background(Color.mpLight.opacity(0.55))
            .macBevel(.sunken)
            .padding(.trailing, 8)
        }
        .padding(.vertical, 3)
        .background(Color.mpMid)
        .overlay(alignment: .top)    { Rectangle().fill(Color.mpLight.opacity(0.75)).frame(height: 1) }
        .overlay(alignment: .bottom) { Rectangle().fill(Color.mpDeep.opacity(0.35)).frame(height: 1) }
    }

    private func contentArea(m: LandingLayoutMetrics) -> some View {
        Group {
            if m.useColumns {
                HStack(alignment: .top, spacing: 0) {
                    leftPane(m: m)
                    Rectangle()
                        .fill(Color.mpDark.opacity(0.30))
                        .frame(width: 1)
                        .padding(.vertical, 6)
                    rightPane(m: m)
                }
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: m.gap) {
                        leftPane(m: m)
                        DotRule()
                        cardStack(m: m)
                    }
                    .padding(.bottom, 10)
                }
            }
        }
        .padding(m.contentPad)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.mpPaper)
    }

    private func leftPane(m: LandingLayoutMetrics) -> some View {
        let content = VStack(alignment: .leading, spacing: m.gap) {

            HStack(alignment: .center, spacing: 11) {
                ZStack {
                    Color.mpBase
                    RainbowApple(fontSize: m.badgeAppleSz)
                }
                .frame(width: m.badgeSz, height: m.badgeSz)
                .macBevel(.raised)

                VStack(alignment: .leading, spacing: -1) {
                    Text("Offline Vision")
                    Text("Telemetry")
                }
                .font(.system(size: m.heroFont, weight: .black))
                .foregroundStyle(Color.mpInk)
                .lineLimit(1)
                .minimumScaleFactor(0.60)
            }

            DotRule()

            Text("On-device ML monitoring with retro Apple-inspired controls. Fully offline - no network required.")
                .font(.system(size: m.bodyFont, weight: .regular))
                .foregroundStyle(Color.mpInk.opacity(0.78))
                .lineSpacing(3.5)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 0) {
                Text("TARGET CLASSES  //  ")
                    .font(.system(size: m.metaFont, weight: .black, design: .monospaced))
                    .foregroundStyle(Color.mpInk.opacity(0.58))
                Text(targetClassText)
                    .font(.system(size: m.metaFont, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.mpInk.opacity(0.80))
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.mpLight)
            .macBevel(.sunken)

            DotRule()

            if m.stackButtons {
                VStack(spacing: 8) {
                    primaryBtn("▶  START MONITOR", m: m, action: onStartTap)
                    secondaryBtn("?  HOW IT WORKS", m: m, action: onLearnTap)
                }
            } else {
                HStack(spacing: 10) {
                    primaryBtn("▶  START MONITOR", m: m, action: onStartTap)
                    secondaryBtn("?  HOW IT WORKS", m: m, action: onLearnTap)
                }
            }

            Spacer(minLength: 0)
        }

        return Group {
            if m.useColumns {
                content
                    .frame(width: m.leftW, alignment: .topLeading)
                    .frame(maxHeight: .infinity, alignment: .topLeading)
                    .padding(.trailing, m.gap)
            } else {
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
    }

    private func primaryBtn(_ label: String, m: LandingLayoutMetrics, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: m.btnFont, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
                .lineLimit(1).minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
                .padding(.vertical, m.btnPadV)
                .padding(.horizontal, 14)
                .background(LinearGradient(colors: [Color.sysBlueLt, Color.sysBlueDk],
                                           startPoint: .top, endPoint: .bottom))
                .macBevel(.raised)
        }.buttonStyle(.plain)
    }

    private func secondaryBtn(_ label: String, m: LandingLayoutMetrics, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: m.btnFont, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.mpInk.opacity(0.85))
                .lineLimit(1).minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
                .padding(.vertical, m.btnPadV)
                .padding(.horizontal, 14)
                .background(Color.mpBase)
                .macBevel(.raised)
        }.buttonStyle(.plain)
    }

    private func rightPane(m: LandingLayoutMetrics) -> some View {
        VStack(alignment: .leading, spacing: m.gap) {
            cardStack(m: m)
            Spacer(minLength: 0)
        }
        .frame(width: m.rightW)
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.leading, m.gap)
    }

    private func cardStack(m: LandingLayoutMetrics) -> some View {
        VStack(spacing: m.gap) {
            InfoCard(title: "TARGET CLASSES",
                     value: targetClassText,
                     symbol: "viewfinder.circle",
                     m: m)
            InfoCard(title: "PROCESSING",
                     value: "On-device inference.\nNo network required.",
                     symbol: "cpu",
                     m: m)
            InfoCard(title: "OUTPUT",
                     value: "Bounding boxes, heat map,\nevent log, captions.",
                     symbol: "display",
                     m: m)
        }
        .frame(maxWidth: .infinity)
    }

    private func statusBar(m: LandingLayoutMetrics) -> some View {
        HStack(spacing: 0) {
            HStack(spacing: 6) {
                ZStack {
                    Circle().fill(Color.sysGreen)
                    Circle().stroke(Color.mpDeep.opacity(0.5), lineWidth: 0.8)
                }.frame(width: 9, height: 9)
                Text("STATUS: OFFLINE")
                    .font(.system(size: m.statusFont, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.mpInk.opacity(0.85))
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(Color.mpLight.opacity(0.65))
            .macBevel(.sunken)
            .padding(.leading, m.contentPad)

            Spacer(minLength: 0)

            HStack(spacing: 6) {
                Image(systemName: "opticaldisc")
                    .font(.system(size: m.statusFont + 1, weight: .medium))
                    .foregroundStyle(Color.mpInk.opacity(0.45))
                Text("0 ERRORS")
                    .font(.system(size: m.statusFont, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.mpInk.opacity(0.45))
            }
            .padding(.trailing, m.contentPad)
        }
        .padding(.vertical, 7)
        .background(Color.mpMid)
        .overlay(alignment: .top) {
            Rectangle().fill(Color.mpDeep.opacity(0.30)).frame(height: 1)
        }
    }
}

struct LandingLayoutMetrics {
    let size: CGSize

    var outerPad: CGFloat { clamp(size.width * 0.025, lo: 12, hi: 26) }

    private var brandZoneH: CGFloat { outerPad + brandAppleSz + brandLabelSz * 3 + 16 }

    var windowW: CGFloat {
        clamp(size.width - outerPad * 2.4, lo: 460, hi: 1040)
    }
    var windowH: CGFloat {
        let available = size.height - brandZoneH - outerPad
        return clamp(available, lo: 320, hi: 620)
    }

    func windowCY(total: CGSize) -> CGFloat {
        let topEdge = brandZoneH + windowH * 0.5
        let botEdge = total.height - windowH * 0.5 - outerPad * 0.5
        let prefer  = brandZoneH + (total.height - brandZoneH - windowH) * 0.50 + windowH * 0.5
        return clamp(prefer, lo: topEdge, hi: botEdge)
    }

    var useColumns:   Bool { windowW >= 660 }
    var stackButtons: Bool { windowW < 520  }

    private var innerW: CGFloat { windowW - contentPad * 2 - 1 }

    var leftW: CGFloat {
        guard useColumns else { return innerW }
        return clamp(innerW * 0.52, lo: 210, hi: 520)
    }
    var rightW: CGFloat {
        guard useColumns else { return innerW }
        return max(0, innerW - leftW - gap)
    }

    var contentPad: CGFloat { windowW < 680 ? 11 : 15 }
    var gap:        CGFloat { windowW < 680 ?  8 : 12 }

    var titleBarH:    CGFloat { windowW < 680 ? 26 : 30 }
    var titleBarFont: CGFloat { windowW < 680 ? 11 : 13 }
    var menuFont:     CGFloat { windowW < 680 ? 11 : 13 }
    var statusFont:   CGFloat { windowW < 680 ?  9 : 11 }

    var heroFont: CGFloat { windowW < 680 ? 32 : windowW < 880 ? 42 : 52 }
    var bodyFont: CGFloat { windowW < 680 ? 11 : 13 }
    var metaFont: CGFloat { windowW < 680 ?  9 : 11 }
    var btnFont:  CGFloat { windowW < 680 ? 11 : 13 }
    var btnPadV:  CGFloat { windowW < 680 ?  7 :  9 }

    var cardTitleH:    CGFloat { windowW < 680 ? 22 : 26 }
    var cardTitleFont: CGFloat { windowW < 680 ?  9 : 11 }
    var cardBodyFont:  CGFloat { windowW < 680 ? 10 : 12 }

    var badgeSz:      CGFloat { windowW < 680 ? 42 : 54 }
    var badgeAppleSz: CGFloat { windowW < 680 ? 19 : 26 }

    var brandAppleSz: CGFloat { size.width < 860 ? 22 : 28 }
    var brandLabelSz: CGFloat { size.width < 860 ? 10 : 12 }

    private func clamp(_ v: CGFloat, lo: CGFloat, hi: CGFloat) -> CGFloat {
        Swift.max(lo, Swift.min(hi, v))
    }
}
