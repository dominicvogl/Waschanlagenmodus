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
            Text("Tastatur gesperrt – Zeit zum Putzen 🫧")
            if let endsAt = blocker.endsAt {
                Text("Automatisches Ende um \(endsAt, style: .time)")
            }
            Button("Waschanlagenmodus beenden") { blocker.stop() }
        } else {
            Button("Waschanlagenmodus starten") { blocker.start() }
        }

        switch blocker.problem {
        case .missingPermission:
            Divider()
            Text("Bedienungshilfen-Zugriff erforderlich")
            Button("Systemeinstellungen öffnen …") { KeyboardBlocker.openAccessibilitySettings() }
        case .needsRestart:
            Divider()
            Text("Bitte App neu starten, damit die Berechtigung greift")
        case nil:
            EmptyView()
        }

        Divider()
        Button("App beenden") { NSApplication.shared.terminate(nil) }
    }
}
