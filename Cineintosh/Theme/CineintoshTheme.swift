import CoreText
import SwiftUI

extension Color {
    static let cineintoshWhite = Color(red: 1, green: 1, blue: 1)
    static let cineintoshInk = Color(red: 30 / 255, green: 46 / 255, blue: 55 / 255)
    static let cineintoshTagTeal = Color(red: 83 / 255, green: 148 / 255, blue: 180 / 255, opacity: 0.5)
    static let cineintoshRetroTitleBlue = Color(red: 0.02, green: 0.04, blue: 0.56)
    static let cineintoshRetroSurface = Color(red: 0.84, green: 0.84, blue: 0.81)
    static let cineintoshRetroInset = Color(red: 0.76, green: 0.76, blue: 0.73)
    static let cineintoshRetroHighlight = Color.white.opacity(0.96)
    static let cineintoshRetroShadow = Color(red: 0.35, green: 0.35, blue: 0.35)
    static let cineintoshRetroBorder = Color.black.opacity(0.8)
}

enum CineintoshFonts {
    static func antonSC(size: CGFloat) -> Font {
        Font.custom("Anton SC", size: size)
    }

    static func interDisplay(size: CGFloat, weight: Font.Weight) -> Font {
        Font.custom("Inter", size: size).weight(weight)
    }

    static func manrope(size: CGFloat, weight: Font.Weight) -> Font {
        Font.custom("Manrope", size: size).weight(weight)
    }
}

enum FontLoader {
    static func registerBundledFonts() {
        guard let resourcesURL = Bundle.main.resourceURL else { return }
        guard let enumerator = FileManager.default.enumerator(at: resourcesURL, includingPropertiesForKeys: nil) else { return }

        for case let fontURL as URL in enumerator where ["ttf", "otf"].contains(fontURL.pathExtension.lowercased()) {
            CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
        }
    }
}

enum CineintoshObjectClasses {
    static let filter = ["person", "book", "pen", "cup", "banana"]
}

private struct CineintoshRetroBevel: ViewModifier {
    let pressed: Bool

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(pressed ? Color.cineintoshRetroShadow : Color.cineintoshRetroHighlight)
                    .frame(height: 1)
            }
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(pressed ? Color.cineintoshRetroShadow : Color.cineintoshRetroHighlight)
                    .frame(width: 1)
            }
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(pressed ? Color.cineintoshRetroHighlight : Color.cineintoshRetroShadow)
                    .frame(height: 1)
            }
            .overlay(alignment: .trailing) {
                Rectangle()
                    .fill(pressed ? Color.cineintoshRetroHighlight : Color.cineintoshRetroShadow)
                    .frame(width: 1)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color.cineintoshRetroBorder, lineWidth: 1)
            )
    }
}

extension View {
    func cineintoshRetroBevel(pressed: Bool = false) -> some View {
        modifier(CineintoshRetroBevel(pressed: pressed))
    }
}
