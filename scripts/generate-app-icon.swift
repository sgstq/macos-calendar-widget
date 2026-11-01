#!/usr/bin/env swift
// Renders the Calendar Widget app icon into App/Assets.xcassets/AppIcon.appiconset.
//
// Usage:  swift scripts/generate-app-icon.swift
// (re-run only when the icon design changes; the PNGs are committed)
//
// Design: a dark glass tile with a faint month grid of dots and one accent
// "today" dot — the same language as the widget itself.

import AppKit

let root = URL(fileURLWithPath: CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : "App/Assets.xcassets/AppIcon.appiconset")

try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)

func render(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()
    defer { image.unlockFocus() }
    guard let ctx = NSGraphicsContext.current?.cgContext else { return image }

    // macOS icon grid: the artwork sits inside ~80% of the canvas.
    let inset = size * 0.1
    let tile = CGRect(x: inset, y: inset, width: size - 2 * inset, height: size - 2 * inset)
    let radius = tile.width * 0.225
    let path = CGPath(roundedRect: tile, cornerWidth: radius, cornerHeight: radius, transform: nil)

    // Soft shadow under the tile.
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -size * 0.012), blur: size * 0.04,
                  color: NSColor.black.withAlphaComponent(0.35).cgColor)
    ctx.addPath(path)
    ctx.setFillColor(NSColor(calibratedWhite: 0.13, alpha: 1).cgColor)
    ctx.fillPath()
    ctx.restoreGState()

    // Glass gradient: lighter at the top, darker at the bottom.
    ctx.saveGState()
    ctx.addPath(path)
    ctx.clip()
    let colors = [
        NSColor(calibratedWhite: 0.26, alpha: 1).cgColor,
        NSColor(calibratedWhite: 0.12, alpha: 1).cgColor,
    ] as CFArray
    if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1]) {
        ctx.drawLinearGradient(gradient,
                               start: CGPoint(x: tile.midX, y: tile.maxY),
                               end: CGPoint(x: tile.midX, y: tile.minY),
                               options: [])
    }
    // Specular highlight along the top edge.
    let highlight = [
        NSColor.white.withAlphaComponent(0.22).cgColor,
        NSColor.white.withAlphaComponent(0.0).cgColor,
    ] as CFArray
    if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: highlight, locations: [0, 1]) {
        ctx.drawLinearGradient(gradient,
                               start: CGPoint(x: tile.midX, y: tile.maxY),
                               end: CGPoint(x: tile.midX, y: tile.maxY - tile.height * 0.35),
                               options: [])
    }
    ctx.restoreGState()

    // Thin inner border.
    ctx.saveGState()
    ctx.addPath(path)
    ctx.setStrokeColor(NSColor.white.withAlphaComponent(0.12).cgColor)
    ctx.setLineWidth(max(1, size * 0.006))
    ctx.strokePath()
    ctx.restoreGState()

    // Month grid: 7 columns x 5 rows of dots, one accent dot for "today".
    let cols = 7, rows = 5
    let gridInset = tile.width * 0.2
    let grid = tile.insetBy(dx: gridInset, dy: gridInset)
    let stepX = grid.width / CGFloat(cols - 1)
    let stepY = grid.height / CGFloat(rows - 1)
    let dot = tile.width * 0.03
    let today = (col: 3, row: 2)

    for row in 0..<rows {
        for col in 0..<cols {
            let center = CGPoint(x: grid.minX + CGFloat(col) * stepX,
                                 y: grid.maxY - CGFloat(row) * stepY)
            let isToday = col == today.col && row == today.row
            let isWeekend = col >= 5
            let r = isToday ? dot * 2.1 : dot
            let rect = CGRect(x: center.x - r, y: center.y - r, width: 2 * r, height: 2 * r)
            if isToday {
                ctx.saveGState()
                ctx.setShadow(offset: .zero, blur: size * 0.03,
                              color: NSColor.systemRed.withAlphaComponent(0.7).cgColor)
                ctx.setFillColor(NSColor.systemRed.cgColor)
                ctx.fillEllipse(in: rect)
                ctx.restoreGState()
            } else {
                ctx.setFillColor(NSColor.white.withAlphaComponent(isWeekend ? 0.35 : 0.8).cgColor)
                ctx.fillEllipse(in: rect)
            }
        }
    }
    return image
}

func writePNG(_ image: NSImage, pixels: Int, to url: URL) throws {
    guard let tiff = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff) else { throw NSError(domain: "icon", code: 1) }
    // Re-render at exact pixel size so @2x variants are truly 2x.
    let target = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels,
                                  bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                                  colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    target.size = NSSize(width: pixels, height: pixels)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: target)
    rep.draw(in: NSRect(x: 0, y: 0, width: pixels, height: pixels))
    NSGraphicsContext.restoreGraphicsState()
    guard let png = target.representation(using: .png, properties: [:]) else { throw NSError(domain: "icon", code: 2) }
    try png.write(to: url)
}

// Standard macOS icon set.
let specs: [(points: Int, scale: Int)] = [
    (16, 1), (16, 2), (32, 1), (32, 2), (128, 1), (128, 2), (256, 1), (256, 2), (512, 1), (512, 2),
]

var images: [[String: String]] = []
for spec in specs {
    let pixels = spec.points * spec.scale
    let filename = "icon_\(spec.points)x\(spec.points)\(spec.scale == 2 ? "@2x" : "").png"
    try writePNG(render(size: CGFloat(pixels)), pixels: pixels, to: root.appendingPathComponent(filename))
    images.append([
        "filename": filename,
        "idiom": "mac",
        "scale": "\(spec.scale)x",
        "size": "\(spec.points)x\(spec.points)",
    ])
}

let contents: [String: Any] = [
    "images": images,
    "info": ["author": "xcode", "version": 1],
]
let json = try JSONSerialization.data(withJSONObject: contents, options: [.prettyPrinted, .sortedKeys])
try json.write(to: root.appendingPathComponent("Contents.json"))
print("Wrote \(images.count) icons to \(root.path)")
