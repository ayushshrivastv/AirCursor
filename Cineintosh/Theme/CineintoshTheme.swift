import CoreText
import SwiftUI

extension Color {
    static let cineintoshWhite = Color(red: 1, green: 1, blue: 1)
    static let cineintoshInk = Color(red: 30 / 255, green: 46 / 255, blue: 55 / 255)
    static let cineintoshTagTeal = Color(red: 83 / 255, green: 148 / 255, blue: 180 / 255, opacity: 0.5)
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
