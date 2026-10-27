// Justgram
import Foundation
import Postbox
import SwiftSignalKit

public let justgramStoriesDisabled = true
public let justgramPromosDisabled = true

public struct JustgramSettings: Codable, Equatable {
    public static let inactivityOptions: [Int32] = [0, 7, 14, 30, 90]

    public var hideInactiveAfterDays: Int32
    public var hideUnreadInactive: Bool
    public var hideChannels: Bool
    public var grayscale: Bool

    public static var defaultSettings: JustgramSettings {
        return JustgramSettings(hideInactiveAfterDays: 0, hideUnreadInactive: false, hideChannels: false, grayscale: false)
    }

    public init(hideInactiveAfterDays: Int32, hideUnreadInactive: Bool, hideChannels: Bool, grayscale: Bool) {
        self.hideInactiveAfterDays = hideInactiveAfterDays
        self.hideUnreadInactive = hideUnreadInactive
        self.hideChannels = hideChannels
        self.grayscale = grayscale
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        self.hideInactiveAfterDays = try container.decodeIfPresent(Int32.self, forKey: "hideInactiveAfterDays") ?? 0
        self.hideUnreadInactive = try container.decodeIfPresent(Bool.self, forKey: "hideUnreadInactive") ?? false
        self.hideChannels = try container.decodeIfPresent(Bool.self, forKey: "hideChannels") ?? false
        self.grayscale = try container.decodeIfPresent(Bool.self, forKey: "grayscale") ?? false
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encode(self.hideInactiveAfterDays, forKey: "hideInactiveAfterDays")
        try container.encode(self.hideUnreadInactive, forKey: "hideUnreadInactive")
        try container.encode(self.hideChannels, forKey: "hideChannels")
        try container.encode(self.grayscale, forKey: "grayscale")
    }

    public var isChatListFilterActive: Bool {
        return self.hideInactiveAfterDays > 0 || self.hideChannels
    }

    public func inactivityCutoff(now: Int32) -> Int32? {
        if self.hideInactiveAfterDays > 0 {
            return now - self.hideInactiveAfterDays * 24 * 60 * 60
        } else {
            return nil
        }
    }
}

public let justgramSettingsKey: ValueBoxKey = applicationSpecificSharedDataKey(100)

public func justgramSettings(accountManager: AccountManager<TelegramAccountManagerTypes>) -> Signal<JustgramSettings, NoError> {
    return accountManager.sharedData(keys: [justgramSettingsKey])
    |> map { sharedData -> JustgramSettings in
        return sharedData.entries[justgramSettingsKey]?.get(JustgramSettings.self) ?? .defaultSettings
    }
    |> distinctUntilChanged
}

public func updateJustgramSettingsInteractively(accountManager: AccountManager<TelegramAccountManagerTypes>, _ f: @escaping (JustgramSettings) -> JustgramSettings) -> Signal<Void, NoError> {
    return accountManager.transaction { transaction -> Void in
        transaction.updateSharedData(justgramSettingsKey, { entry in
            let currentSettings = entry?.get(JustgramSettings.self) ?? .defaultSettings
            return SharedPreferencesEntry(f(currentSettings))
        })
    }
}

/// Synchronous mirror of the settings for hot paths that can't subscribe to signals.
public final class JustgramSettingsStore {
    public static let shared = JustgramSettingsStore()

    private let value = Atomic<JustgramSettings>(value: .defaultSettings)
    private let promise = Promise<JustgramSettings>()
    private var disposable: Disposable?

    public var current: JustgramSettings {
        return self.value.with { $0 }
    }

    public var updates: Signal<JustgramSettings, NoError> {
        return self.promise.get()
    }

    /// Starts mirroring the settings; the returned signal completes once the first value is loaded.
    public func bind(accountManager: AccountManager<TelegramAccountManagerTypes>) -> Signal<Void, NoError> {
        if self.disposable == nil {
            self.disposable = (justgramSettings(accountManager: accountManager)
            |> deliverOnMainQueue).start(next: { [weak self] settings in
                guard let self else {
                    return
                }
                let _ = self.value.swap(settings)
                self.promise.set(.single(settings))
            })
        }
        return self.promise.get()
        |> take(1)
        |> map { _ -> Void in
            return Void()
        }
    }
}

/// Current time quantized to `granularity`, refreshed periodically and whenever the app returns to foreground.
public func justgramClock(foreground: Signal<Bool, NoError>, granularity: Int32 = 60 * 60) -> Signal<Int32, NoError> {
    let tick = Signal<Void, NoError> { subscriber in
        subscriber.putNext(Void())
        let timer = SwiftSignalKit.Timer(timeout: Double(granularity) / 4.0, repeat: true, completion: {
            subscriber.putNext(Void())
        }, queue: Queue.mainQueue())
        timer.start()
        return ActionDisposable {
            timer.invalidate()
        }
    }
    let wake: Signal<Void, NoError> = .single(Void())
    |> then(
        foreground
        |> filter { $0 }
        |> map { _ -> Void in
            return Void()
        }
    )
    return combineLatest(tick, wake)
    |> map { _ -> Int32 in
        let now = Int32(Date().timeIntervalSince1970)
        return now - now % granularity
    }
    |> distinctUntilChanged
}
