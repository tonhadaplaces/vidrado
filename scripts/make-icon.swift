import AppKit

// Original vector artwork, rendered with AppKit at each required icon size.
let output = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
for size in [16, 32, 128, 256, 512] {
    for scale in [1, 2] {
        let pixels = size * scale
        let image = NSImage(size: NSSize(width: pixels, height: pixels))
        image.lockFocus()
        let transform = NSAffineTransform(); transform.scale(by: CGFloat(pixels) / 1024); transform.concat()
        let background = NSBezierPath(roundedRect: NSRect(x: 24, y: 24, width: 976, height: 976), xRadius: 218, yRadius: 218)
        NSGradient(starting: NSColor(calibratedRed: 0.27, green: 0.47, blue: 0.43, alpha: 1), ending: NSColor(calibratedRed: 0.12, green: 0.29, blue: 0.28, alpha: 1))!.draw(in: background, angle: -55)
        for inset in stride(from: 0, through: 70, by: 7) {
            NSColor.white.withAlphaComponent(0.012).setFill()
            NSBezierPath(roundedRect: NSRect(x: 155 - inset, y: 225 - inset, width: 430 + inset * 2, height: 420 + inset * 2), xRadius: 90, yRadius: 90).fill()
        }
        NSColor.white.withAlphaComponent(0.19).setFill()
        NSBezierPath(roundedRect: NSRect(x: 169, y: 236, width: 400, height: 435), xRadius: 64, yRadius: 64).fill()
        let front = NSBezierPath(roundedRect: NSRect(x: 350, y: 324, width: 475, height: 420), xRadius: 60, yRadius: 60)
        NSColor(calibratedRed: 0.96, green: 0.96, blue: 0.9, alpha: 1).setFill(); front.fill()
        NSColor(calibratedRed: 0.31, green: 0.49, blue: 0.43, alpha: 0.65).setFill()
        for x in [402, 438, 474] { NSBezierPath(ovalIn: NSRect(x: x, y: 673, width: 17, height: 17)).fill() }
        for (y, width) in [(580, 290), (520, 238), (460, 269)] {
            NSColor(calibratedRed: 0.31, green: 0.49, blue: 0.43, alpha: 0.25).setFill()
            NSBezierPath(roundedRect: NSRect(x: 406, y: y, width: width, height: 18), xRadius: 9, yRadius: 9).fill()
        }
        image.unlockFocus()
        let bitmap = NSBitmapImageRep(data: image.tiffRepresentation!)!
        let name = "icon_\(size)x\(size)\(scale == 2 ? "@2x" : "").png"
        try bitmap.representation(using: .png, properties: [:])!.write(to: output.appendingPathComponent(name))
    }
}
