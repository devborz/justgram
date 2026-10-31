import Foundation
import UIKit
import Display
import TelegramPresentationData

// Settings row icon: the app icon's feature phone in white on a black settings square.
let justgramSettingsIcon: UIImage? = {
    guard let background = renderSettingsIcon(name: "", backgroundColors: [UIColor(rgb: 0x000000)]) else {
        return nil
    }
    let size = background.size
    let format = UIGraphicsImageRendererFormat()
    format.scale = background.scale
    let glyph = UIGraphicsImageRenderer(size: size, format: format).image { context in
        justgramDrawPhone(context.cgContext, center: CGPoint(x: size.width * 0.5, y: size.height * 0.5), height: 20.0)
    }
    return UIGraphicsImageRenderer(size: size, format: format).image { _ in
        background.draw(in: CGRect(origin: .zero, size: size))
        glyph.draw(in: CGRect(origin: .zero, size: size))
    }
}()

/// Draws the phone in white with its screen and keys cut out. The geometry is the app icon layer's
/// (Telegram.icon/Assets/Phone.svg, a 256-point grid scaled x3), fitted so the phone is `height` points tall.
private func justgramDrawPhone(_ context: CGContext, center: CGPoint, height: CGFloat) {
    context.saveGState()
    context.translateBy(x: center.x, y: center.y)
    context.scaleBy(x: height / 200.0, y: height / 200.0)
    context.translateBy(x: -128.0, y: -126.0)

    context.setFillColor(UIColor.white.cgColor)
    context.addPath(CGPath(roundedRect: CGRect(x: 80.0, y: 58.0, width: 96.0, height: 168.0), cornerWidth: 28.0, cornerHeight: 28.0, transform: nil))
    context.addPath(CGPath(roundedRect: CGRect(x: 148.0, y: 26.0, width: 16.0, height: 46.0), cornerWidth: 8.0, cornerHeight: 8.0, transform: nil))
    context.fillPath()

    context.setBlendMode(.clear)
    context.addPath(CGPath(roundedRect: CGRect(x: 94.0, y: 74.0, width: 68.0, height: 62.0), cornerWidth: 12.0, cornerHeight: 12.0, transform: nil))
    for y: CGFloat in [158.0, 182.0, 206.0] {
        for x: CGFloat in [104.0, 128.0, 152.0] {
            context.addEllipse(in: CGRect(x: x - 8.0, y: y - 8.0, width: 16.0, height: 16.0))
        }
    }
    context.fillPath()
    context.restoreGState()
}
