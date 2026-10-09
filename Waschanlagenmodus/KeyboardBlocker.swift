import AppKit
import ApplicationServices
import Observation

/// Verschluckt alle Tastatur-Events über einen CGEventTap, solange der Modus aktiv ist.
@Observable
final class KeyboardBlocker {
    static let autoStopDelay: Duration = .seconds(120)

    enum Problem { case missingPermission, needsRestart }

    private(set) var isActive = false
    private(set) var endsAt: Date?
    private(set) var problem: Problem?

    @ObservationIgnored private var tap: CFMachPort?
    @ObservationIgnored private var source: CFRunLoopSource?
    @ObservationIgnored private var autoStopTask: Task<Void, Never>?

    /// NX_SYSDEFINED – Helligkeit, Lautstärke, Media-Tasten (Subtyp 8).
    private static let systemDefinedType: UInt32 = 14
    private static let auxControlButtonsSubtype: Int16 = 8

    func toggle() { isActive ? stop() : start() }

    func start() {
        guard !isActive else { return }

        let prompt = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        guard AXIsProcessTrustedWithOptions(prompt) else {
            problem = .missingPermission
            return
        }

        let mask: CGEventMask =
            (1 << CGEventType.keyDown.rawValue) |
            (1 << CGEventType.keyUp.rawValue) |
            (1 << CGEventType.flagsChanged.rawValue) |
            (1 << Self.systemDefinedType)

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: { _, type, event, userInfo in
                switch type {
                case .tapDisabledByTimeout, .tapDisabledByUserInput:
                    if let userInfo {
                        let blocker = Unmanaged<KeyboardBlocker>.fromOpaque(userInfo).takeUnretainedValue()
                        if let tap = blocker.tap { CGEvent.tapEnable(tap: tap, enable: true) }
                    }
                    return Unmanaged.passUnretained(event)
                case .keyDown, .keyUp, .flagsChanged:
                    return nil
                default:
                    if type.rawValue == KeyboardBlocker.systemDefinedType,
                       NSEvent(cgEvent: event)?.subtype.rawValue == KeyboardBlocker.auxControlButtonsSubtype {
                        return nil
                    }
                    return Unmanaged.passUnretained(event)
                }
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            // Berechtigung ist erteilt, aber TCC greift oft erst nach einem Neustart der App.
            problem = .needsRestart
            return
        }

        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        // commonModes: Tap läuft auch weiter, während das Menü offen ist.
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)

        self.tap = tap
        self.source = source
        problem = nil
        isActive = true
        endsAt = .now.addingTimeInterval(TimeInterval(Self.autoStopDelay.components.seconds))

        autoStopTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: Self.autoStopDelay)
            guard !Task.isCancelled else { return }
            self?.stop()
        }
    }

    func stop() {
        autoStopTask?.cancel()
        autoStopTask = nil

        if let tap {
            CGEvent.tapEnable(tap: tap, enable: false)
            CFMachPortInvalidate(tap)
        }
        if let source {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }
        tap = nil
        source = nil
        endsAt = nil
        isActive = false
    }

    static func openAccessibilitySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }
}
