import Foundation
import UIKit
import Display
import TelegramPresentationData

// Settings row icon: a white leaf on the standard teal settings square.
let justgramSettingsIcon: UIImage? = {
    guard let background = renderSettingsIcon(name: "", backgroundColors: [UIColor(rgb: 0x00c7be)]) else {
        return nil
    }
    let configuration = UIImage.SymbolConfiguration(pointSize: 16.0, weight: .semibold)
    guard let leaf = UIImage(systemName: "leaf.fill", withConfiguration: configuration)?.withTintColor(.white, renderingMode: .alwaysOriginal) else {
        return background
    }
    let size = background.size
    let renderer = UIGraphicsImageRenderer(size: size, format: {
        let format = UIGraphicsImageRendererFormat()
        format.scale = background.scale
        return format
    }())
    return renderer.image { _ in
        background.draw(in: CGRect(origin: .zero, size: size))
        let leafSize = leaf.size
        leaf.draw(in: CGRect(origin: CGPoint(x: floor((size.width - leafSize.width) * 0.5), y: floor((size.height - leafSize.height) * 0.5)), size: leafSize))
    }
}()
