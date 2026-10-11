import AppKit

// Rendert das App-Icon (1024 px) komplett aus eigenen Pfaden – keine SF Symbols.
let out = CommandLine.arguments[1]
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: 1024, pixelsHigh: 1024,
                           bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                           colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
let ctx = NSGraphicsContext.current!

// Hintergrund
let body = NSBezierPath(roundedRect: NSRect(x: 100, y: 100, width: 824, height: 824), xRadius: 185, yRadius: 185)
ctx.saveGraphicsState()
let shadow = NSShadow()
shadow.shadowColor = NSColor.black.withAlphaComponent(0.3)
shadow.shadowBlurRadius = 20
shadow.shadowOffset = NSSize(width: 0, height: -10)
shadow.set()
NSColor.white.setFill(); body.fill()
ctx.restoreGraphicsState()
NSGradient(colors: [NSColor(red: 0.36, green: 0.80, blue: 1.0, alpha: 1),
                    NSColor(red: 0.05, green: 0.38, blue: 0.92, alpha: 1)])!.draw(in: body, angle: -90)

let white = NSColor.white
let keyBlue = NSColor(red: 0.16, green: 0.52, blue: 0.95, alpha: 1)

// Tastatur
let kb = NSRect(x: 262, y: 230, width: 500, height: 300)
white.setFill(); NSBezierPath(roundedRect: kb, xRadius: 70, yRadius: 70).fill()
keyBlue.setFill(); NSBezierPath(roundedRect: kb.insetBy(dx: 40, dy: 40), xRadius: 34, yRadius: 34).fill()
white.setFill()
let inner = kb.insetBy(dx: 72, dy: 68)
let cols = 6, key: CGFloat = 40
let gapX = (inner.width - CGFloat(cols) * key) / CGFloat(cols - 1)
let gapY = (inner.height - 3 * key) / 2
for row in 0..<3 {
    let y = inner.maxY - key - CGFloat(row) * (key + gapY)
    if row == 2 {
        NSBezierPath(roundedRect: NSRect(x: inner.minX, y: y, width: key, height: key), xRadius: 10, yRadius: 10).fill()
        NSBezierPath(roundedRect: NSRect(x: inner.minX + key + gapX, y: y, width: inner.width - 2 * (key + gapX), height: key), xRadius: 10, yRadius: 10).fill()
        NSBezierPath(roundedRect: NSRect(x: inner.maxX - key, y: y, width: key, height: key), xRadius: 10, yRadius: 10).fill()
    } else {
        for c in 0..<cols {
            let x = inner.minX + CGFloat(c) * (key + gapX)
            NSBezierPath(roundedRect: NSRect(x: x, y: y, width: key, height: key), xRadius: 10, yRadius: 10).fill()
        }
    }
}

// Seifenblasen
func bubble(_ cx: CGFloat, _ cy: CGFloat, _ r: CGFloat) {
    let rect = NSRect(x: cx - r, y: cy - r, width: 2 * r, height: 2 * r)
    white.withAlphaComponent(0.25).setFill(); NSBezierPath(ovalIn: rect).fill()
    white.setStroke()
    let ring = NSBezierPath(ovalIn: rect.insetBy(dx: 7, dy: 7)); ring.lineWidth = 14; ring.stroke()
    white.setFill()
    NSBezierPath(ovalIn: NSRect(x: cx - r * 0.5, y: cy + r * 0.2, width: r * 0.32, height: r * 0.32)).fill()
}
bubble(560, 680, 92)
bubble(420, 630, 56)
bubble(680, 800, 48)

// Funkeln (4-zackiger Stern)
func sparkle(_ cx: CGFloat, _ cy: CGFloat, _ r: CGFloat) {
    let p = NSBezierPath(), w = r * 0.22
    p.move(to: NSPoint(x: cx, y: cy + r))
    p.curve(to: NSPoint(x: cx + r, y: cy), controlPoint1: NSPoint(x: cx + w, y: cy + w), controlPoint2: NSPoint(x: cx + w, y: cy + w))
    p.curve(to: NSPoint(x: cx, y: cy - r), controlPoint1: NSPoint(x: cx + w, y: cy - w), controlPoint2: NSPoint(x: cx + w, y: cy - w))
    p.curve(to: NSPoint(x: cx - r, y: cy), controlPoint1: NSPoint(x: cx - w, y: cy - w), controlPoint2: NSPoint(x: cx - w, y: cy - w))
    p.curve(to: NSPoint(x: cx, y: cy + r), controlPoint1: NSPoint(x: cx - w, y: cy + w), controlPoint2: NSPoint(x: cx - w, y: cy + w))
    white.setFill(); p.fill()
}
sparkle(395, 790, 46)
sparkle(720, 625, 36)

NSGraphicsContext.restoreGraphicsState()
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))
