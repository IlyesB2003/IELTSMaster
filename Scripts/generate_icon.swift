import AppKit
import CoreGraphics
import Foundation

// Converts a 1024x1024 BrandLogo PNG into a crisp transparent-corner macOS AppIcon.icns
// (all required standard + Retina sizes) and an optional transparent squircle PNG for in-app UI.
let args = CommandLine.arguments
guard args.count >= 3 else {
    fputs("Usage: swift generate_icon.swift <input_png> <output_icns> [output_squircle_png]\n", stderr)
    exit(1)
}

let inputPath = args[1]
let outputICNSPath = args[2]
let outputSquirclePath = args.count >= 4 ? args[3] : nil

guard let sourceImage = NSImage(contentsOfFile: inputPath),
      let sourceCG = sourceImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    fputs("Failed to load source logo at \(inputPath)\n", stderr)
    exit(1)
}

// Crop inner squircle area (removing outer dark studio backdrop so the squircle fills macOS HIG bounds cleanly)
let srcW = CGFloat(sourceCG.width)
let srcH = CGFloat(sourceCG.height)
let cropInset = srcW * 0.125
let cropRect = CGRect(x: cropInset, y: cropInset, width: srcW - cropInset * 2, height: srcH - cropInset * 2)
let croppedCG = sourceCG.cropping(to: cropRect) ?? sourceCG

func renderSquirclePNG(pixelSize: Int, padRatio: CGFloat) -> Data {
    let size = CGFloat(pixelSize)
    guard let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixelSize,
        pixelsHigh: pixelSize,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        fputs("Failed to allocate bitmap.\n", stderr)
        exit(1)
    }

    NSGraphicsContext.saveGraphicsState()
    guard let ctx = NSGraphicsContext(bitmapImageRep: rep)?.cgContext else {
        fputs("Failed to create graphics context.\n", stderr)
        exit(1)
    }
    ctx.interpolationQuality = .high
    ctx.clear(CGRect(x: 0, y: 0, width: size, height: size))

    let inset = size * padRatio
    let rect = CGRect(x: inset, y: inset, width: size - inset * 2, height: size - inset * 2)
    let cornerRadius = rect.width * 0.225
    let path = CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)

    // Subtle macOS drop shadow for Dock/Finder depth
    ctx.saveGState()
    if padRatio > 0.01 {
        ctx.setShadow(offset: CGSize(width: 0, height: -size * 0.014), blur: size * 0.028, color: CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 0.35))
        ctx.addPath(path)
        ctx.setFillColor(CGColor(srgbRed: 0.06, green: 0.09, blue: 0.15, alpha: 1))
        ctx.fillPath()
    }
    ctx.restoreGState()

    // Clip and draw high-res emblem
    ctx.saveGState()
    ctx.addPath(path)
    ctx.clip()
    ctx.draw(croppedCG, in: rect)
    ctx.restoreGState()

    // Refined glass rim stroke
    ctx.saveGState()
    ctx.addPath(path)
    ctx.setStrokeColor(CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.18))
    ctx.setLineWidth(max(1.0, size * 0.008))
    ctx.strokePath()
    ctx.restoreGState()

    NSGraphicsContext.restoreGraphicsState()

    guard let pngData = rep.representation(using: .png, properties: [:]) else {
        fputs("Failed to encode PNG.\n", stderr)
        exit(1)
    }
    return pngData
}

func appendBigEndian(_ value: UInt32, to data: inout Data) {
    var be = value.bigEndian
    withUnsafeBytes(of: &be) { data.append(contentsOf: $0) }
}

let entries: [(type: String, px: Int)] = [
    ("icp4", 16),
    ("icp5", 32),
    ("ic11", 32),
    ("ic12", 64),
    ("ic07", 128),
    ("ic13", 256),
    ("ic08", 256),
    ("ic14", 512),
    ("ic09", 512),
    ("ic10", 1024)
]

var body = Data()
for entry in entries {
    let png = renderSquirclePNG(pixelSize: entry.px, padRatio: 0.085)
    body.append(contentsOf: entry.type.utf8)
    appendBigEndian(UInt32(8 + png.count), to: &body)
    body.append(png)
}

var icns = Data()
icns.append(contentsOf: "icns".utf8)
appendBigEndian(UInt32(8 + body.count), to: &icns)
icns.append(body)

try icns.write(to: URL(fileURLWithPath: outputICNSPath))
print("Generated macOS AppIcon.icns (\(icns.count) bytes) at \(outputICNSPath)")

if let sqPath = outputSquirclePath {
    let uiPNG = renderSquirclePNG(pixelSize: 512, padRatio: 0.02)
    try uiPNG.write(to: URL(fileURLWithPath: sqPath))
    print("Generated in-app BrandLogo PNG (\(uiPNG.count) bytes) at \(sqPath)")
}
