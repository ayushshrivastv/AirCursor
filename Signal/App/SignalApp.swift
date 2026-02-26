import AppKit
import SwiftUI

private final class SignalAppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

@main
struct SignalApp: App {
    @NSApplicationDelegateAdaptor(SignalAppDelegate.self) private var appDelegate

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
