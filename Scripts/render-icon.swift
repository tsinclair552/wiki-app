#!/usr/bin/env swift -F /System/Library/Frameworks

import AppKit

let size = 1024

let image = NSImage(size: NSSize(width: size, height: size))
image.lockFocusFlipped(false)

// Rounded rect background (blue #0055B8)
let rect = NSRect(x: 0, y: 0, width: size, height: size)
let path = NSBezierPath(roundedRect: rect, xRadius: CGFloat(size) * 0.17, yRadius: CGFloat(size) * 0.17)
NSColor(red: 0/255, green: 85/255, blue: 184/255, alpha: 1).setFill()
path.fill()

// Book shape
let bookLeft: CGFloat = CGFloat(size) * 0.22
let bookRight: CGFloat = CGFloat(size) * 0.78
let bookTop: CGFloat = CGFloat(size) * 0.18
let bookBottom: CGFloat = CGFloat(size) * 0.82
let bookWidth = bookRight - bookLeft
let bookHeight = bookBottom - bookTop

// Spine (left side — darker book cover)
let spineWidth = bookWidth * 0.18
let spineRect = NSRect(x: bookLeft, y: bookTop, width: spineWidth, height: bookHeight)
let spinePath = NSBezierPath(roundedRect: spineRect, xRadius: 6, yRadius: 6)
NSColor(white: 0.78, alpha: 1).setFill()
spinePath.fill()

// Pages (right side)
let pagesRect = NSRect(x: bookLeft + spineWidth - 2, y: bookTop, width: bookWidth - spineWidth + 2, height: bookHeight)
let pagesPath = NSBezierPath(roundedRect: pagesRect, xRadius: 6, yRadius: 6)
NSColor(white: 0.96, alpha: 1).setFill()
pagesPath.fill()

// Page lines
let lineCount = 6
let lineSpacing = (bookHeight - 20) / CGFloat(lineCount + 1)
for i in 1...lineCount {
    let ly = bookTop + 10 + lineSpacing * CGFloat(i)
    let linePath = NSBezierPath()
    linePath.move(to: NSPoint(x: bookLeft + spineWidth + 8, y: ly))
    linePath.line(to: NSPoint(x: bookRight - 8, y: ly))
    NSColor(white: 0.82, alpha: 1).setStroke()
    linePath.lineWidth = 2
    linePath.stroke()
}

// "W" letter on cover (white, stylized)
func drawW(in rect: NSRect) {
    let wColor = NSColor.white
    let cx = rect.midX
    let cy = rect.midY
    let s: CGFloat = rect.width * 0.35

    let points: [(CGFloat, CGFloat)] = [
        (cx - s * 0.4, cy + s * 0.5),
        (cx - s * 0.35, cy - s * 0.5),
        (cx, cy - s * 0.15),
        (cx + s * 0.35, cy - s * 0.5),
        (cx + s * 0.4, cy + s * 0.5),
    ]

    let wPath = NSBezierPath()
    wPath.move(to: NSPoint(x: points[0].0, y: points[0].1))
    wPath.line(to: NSPoint(x: points[1].0, y: points[1].1))
    wPath.line(to: NSPoint(x: points[2].0, y: points[2].1))
    wPath.line(to: NSPoint(x: points[3].0, y: points[3].1))
    wPath.line(to: NSPoint(x: points[4].0, y: points[4].1))
    wPath.lineWidth = 14
    wPath.lineCapStyle = .round
    wPath.lineJoinStyle = .round
    wColor.setStroke()
    wPath.stroke()
}

drawW(in: NSRect(x: bookLeft, y: bookTop, width: spineWidth, height: bookHeight))

image.unlockFocus()

// Write to PNG
let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
let bitmap = NSBitmapImageRep(cgImage: cgImage)
let pngData = bitmap.representation(using: .png, properties: [:])

let outPath = CommandLine.arguments[1]
try! pngData!.write(to: URL(fileURLWithPath: outPath))
print("Icon rendered: \(outPath)")
