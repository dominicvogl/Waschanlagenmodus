import SwiftUI

@main
struct WaschanlagenmodusApp: App {
    @State private var blocker = KeyboardBlocker()

    var body: some Scene {
        MenuBarExtra {
            MenuContent(blocker: blocker)
        } label: {
            MenuBarLabel(blocker: blocker)
        }
    }
}

private struct MenuBarLabel: View {
    let blocker: KeyboardBlocker

    var body: some View {
        Image(systemName: blocker.isActive ? "bubbles.and.sparkles.fill" : "keyboard")
    }
}

private struct MenuContent: View {
    let blocker: KeyboardBlocker

    var body: some View {
        if blocker.isActive {
            Text("Keyboard locked – time to clean 🫧")
            if let endsAt = blocker.endsAt {
                Text("Ends automatically at \(endsAt.formatted(date: .omitted, time: .shortened))")
            }
            Button("Stop Car Wash Mode") { blocker.stop() }
        } else {
            Button("Start Car Wash Mode") { blocker.start() }
        }

        switch blocker.problem {
        case .missingPermission:
            Divider()
            Text("Accessibility access required")
            Button("Open System Settings…") { KeyboardBlocker.openAccessibilitySettings() }
        case .needsRestart:
            Divider()
            Text("Please restart the app to apply the permission")
        case nil:
            EmptyView()
        }

        Divider()
        Button("Quit App") { NSApplication.shared.terminate(nil) }
    }
}
