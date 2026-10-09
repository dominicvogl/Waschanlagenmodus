# Waschanlagenmodus 🫧

Winzige macOS-Menüleisten-App: Klick aufs Tastatur-Icon → **Waschanlagenmodus starten** → alle Tastatureingaben (inkl. Helligkeit/Lautstärke/Media-Tasten) werden verschluckt. Tastatur putzen, dann per Trackpad/Maus wieder **beenden** – oder einfach warten: nach **2 Minuten** endet der Modus automatisch.

## Build

```sh
xcodegen generate   # nur nötig, wenn project.yml geändert wurde
xcodebuild -project Waschanlagenmodus.xcodeproj -scheme Waschanlagenmodus \
  -configuration Release -derivedDataPath build build
open build/Build/Products/Release/Waschanlagenmodus.app
```

Optional nach `/Applications` kopieren.

## Berechtigung

Beim ersten Start des Modus fragt macOS nach **Bedienungshilfen** (Systemeinstellungen → Datenschutz & Sicherheit → Bedienungshilfen). Erlauben, dann den Modus erneut starten (ggf. App neu starten).

Die App ist ad-hoc signiert: Nach einem Rebuild erkennt macOS sie evtl. nicht wieder – dann den Eintrag in den Bedienungshilfen entfernen und neu hinzufügen. Mit einem Apple-Developer-Zertifikat (`CODE_SIGN_STYLE: Automatic` + `DEVELOPMENT_TEAM` in `project.yml`) bleibt die Berechtigung über Rebuilds erhalten.

## Grenzen

- Power-Taste / Touch ID lassen sich softwareseitig nicht sperren.
- Caps Lock schaltet in der Tastatur-Firmware – die LED kann beim Putzen umspringen.
- Ist anderswo gerade ein Passwortfeld aktiv (Secure Input), gehen Tasten dorthin.
- Stürzt die App ab oder wird beendet, ist die Tastatur sofort wieder frei.
