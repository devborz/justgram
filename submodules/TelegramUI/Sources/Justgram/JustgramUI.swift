// Justgram
import Foundation
import UIKit
import SwiftSignalKit
import TelegramCore
import TelegramUIPreferences

/// Full-window overlay that desaturates everything below it.
final class JustgramGrayscaleOverlay: UIView {
    private static let defaultsKey = "justgram.grayscale"

    private var disposable: Disposable?

    static func install(in window: UIWindow) {
        let overlay = JustgramGrayscaleOverlay(frame: window.bounds)
        window.addSubview(overlay)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.isUserInteractionEnabled = false
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.backgroundColor = .white
        self.layer.compositingFilter = "saturationBlendMode"
        self.layer.zPosition = 10000.0
        self.isHidden = !UserDefaults.standard.bool(forKey: JustgramGrayscaleOverlay.defaultsKey)

        self.disposable = (JustgramSettingsStore.shared.updates
        |> map { $0.grayscale }
        |> distinctUntilChanged
        |> deliverOnMainQueue).start(next: { [weak self] isEnabled in
            guard let self else {
                return
            }
            self.isHidden = !isEnabled
            UserDefaults.standard.set(isEnabled, forKey: JustgramGrayscaleOverlay.defaultsKey)
        })
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        self.disposable?.dispose()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return nil
    }
}
