// Justgram
import Foundation
import TelegramCore
import SwiftSignalKit

public func justgramAdjustRenderedUnreadCount(accountManager: AccountManager<TelegramAccountManagerTypes>, engine: TelegramEngine) -> (Signal<(Int32, RenderedTotalUnreadCountType), NoError>) -> Signal<(Int32, RenderedTotalUnreadCountType), NoError> {
    return { signal in
        return combineLatest(
            signal,
            accountManager.sharedData(keys: [ApplicationSpecificSharedDataKeys.inAppNotificationSettings, justgramSettingsKey]),
            justgramClock(foreground: .single(true))
        )
        |> mapToThrottled { value, sharedData, now -> Signal<(Int32, RenderedTotalUnreadCountType), NoError> in
            let settings = sharedData.entries[justgramSettingsKey]?.get(JustgramSettings.self) ?? .defaultSettings
            if !settings.isChatListFilterActive {
                return .single(value)
            }
            let inAppSettings = sharedData.entries[ApplicationSpecificSharedDataKeys.inAppNotificationSettings]?.get(InAppNotificationSettings.self) ?? .defaultSettings
            return justgramHiddenUnreadCount(engine: engine, settings: settings, category: inAppSettings.totalUnreadCountDisplayStyle.category, statsType: inAppSettings.totalUnreadCountDisplayCategory.statsType, includeTags: inAppSettings.totalUnreadCountIncludeTags, now: now)
            |> map { hidden -> (Int32, RenderedTotalUnreadCountType) in
                return (max(0, value.0 - hidden), value.1)
            }
        }
    }
}
