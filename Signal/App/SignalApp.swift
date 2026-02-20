import SwiftUI

@main
struct SignalApp: App {
    init() {
        FontLoader.registerBundledFonts()
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .frame(minWidth: 700, minHeight: 480)
        }
        .defaultSize(width: 1280, height: 820)
    }
}
