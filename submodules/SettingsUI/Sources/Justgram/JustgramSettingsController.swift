// Justgram
import Foundation
import UIKit
import Display
import SwiftSignalKit
import TelegramCore
import TelegramPresentationData
import ItemListUI
import PresentationDataUtils
import AccountContext

private final class JustgramSettingsControllerArguments {
    let updateDays: (Int32) -> Void
    let updateHideUnread: (Bool) -> Void
    let updateHideChannels: (Bool) -> Void
    let updateGrayscale: (Bool) -> Void

    init(
        updateDays: @escaping (Int32) -> Void,
        updateHideUnread: @escaping (Bool) -> Void,
        updateHideChannels: @escaping (Bool) -> Void,
        updateGrayscale: @escaping (Bool) -> Void
    ) {
        self.updateDays = updateDays
        self.updateHideUnread = updateHideUnread
        self.updateHideChannels = updateHideChannels
        self.updateGrayscale = updateGrayscale
    }
}

private enum JustgramSettingsSection: Int32 {
    case inactive
    case unread
    case channels
    case calm
}

private enum JustgramSettingsEntry: ItemListNodeEntry {
    case inactiveHeader(String)
    case inactiveOption(index: Int32, title: String, days: Int32, isSelected: Bool)
    case inactiveFooter(String)

    case hideUnread(title: String, value: Bool, isEnabled: Bool)
    case hideUnreadFooter(String)

    case hideChannels(title: String, value: Bool)
    case hideChannelsFooter(String)

    case calmHeader(String)
    case grayscale(title: String, value: Bool)
    case calmFooter(String)

    var section: ItemListSectionId {
        switch self {
        case .inactiveHeader, .inactiveOption, .inactiveFooter:
            return JustgramSettingsSection.inactive.rawValue
        case .hideUnread, .hideUnreadFooter:
            return JustgramSettingsSection.unread.rawValue
        case .hideChannels, .hideChannelsFooter:
            return JustgramSettingsSection.channels.rawValue
        case .calmHeader, .grayscale, .calmFooter:
            return JustgramSettingsSection.calm.rawValue
        }
    }

    var stableId: Int32 {
        switch self {
        case .inactiveHeader:
            return 0
        case let .inactiveOption(index, _, _, _):
            return 1 + index
        case .inactiveFooter:
            return 100
        case .hideUnread:
            return 101
        case .hideUnreadFooter:
            return 102
        case .hideChannels:
            return 103
        case .hideChannelsFooter:
            return 104
        case .calmHeader:
            return 105
        case .grayscale:
            return 107
        case .calmFooter:
            return 108
        }
    }

    static func <(lhs: JustgramSettingsEntry, rhs: JustgramSettingsEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }

    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! JustgramSettingsControllerArguments
        switch self {
        case let .inactiveHeader(text), let .calmHeader(text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, sectionId: self.section)
        case let .inactiveOption(_, title, days, isSelected):
            return ItemListCheckboxItem(presentationData: presentationData, systemStyle: .glass, title: title, style: .left, checked: isSelected, zeroSeparatorInsets: false, sectionId: self.section, action: {
                arguments.updateDays(days)
            })
        case let .inactiveFooter(text), let .hideUnreadFooter(text), let .hideChannelsFooter(text), let .calmFooter(text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        case let .hideUnread(title, value, isEnabled):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: title, value: value, enabled: isEnabled, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateHideUnread(value)
            })
        case let .hideChannels(title, value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: title, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateHideChannels(value)
            })
        case let .grayscale(title, value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: title, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateGrayscale(value)
            })
        }
    }
}

private func justgramSettingsEntries(presentationData: PresentationData, settings: JustgramSettings) -> [JustgramSettingsEntry] {
    let strings = JustgramStrings(strings: presentationData.strings)
    var entries: [JustgramSettingsEntry] = []

    entries.append(.inactiveHeader(strings.inactiveHeader))
    for (index, days) in JustgramSettings.inactivityOptions.enumerated() {
        entries.append(.inactiveOption(index: Int32(index), title: strings.days(days), days: days, isSelected: settings.hideInactiveAfterDays == days))
    }
    entries.append(.inactiveFooter(strings.inactiveFooter))

    entries.append(.hideUnread(title: strings.hideUnread, value: settings.hideUnreadInactive, isEnabled: settings.hideInactiveAfterDays != 0))
    entries.append(.hideUnreadFooter(strings.hideUnreadFooter))

    entries.append(.hideChannels(title: strings.hideChannels, value: settings.hideChannels))
    entries.append(.hideChannelsFooter(strings.hideChannelsFooter))

    entries.append(.calmHeader(strings.calmHeader))
    entries.append(.grayscale(title: strings.grayscale, value: settings.grayscale))
    entries.append(.calmFooter(strings.calmFooter))

    return entries
}

public func justgramSettingsController(context: AccountContext) -> ViewController {
    let accountManager = context.sharedContext.accountManager
    let update: (@escaping (JustgramSettings) -> JustgramSettings) -> Void = { f in
        let _ = updateJustgramSettingsInteractively(accountManager: accountManager, f).start()
    }

    let arguments = JustgramSettingsControllerArguments(
        updateDays: { value in
            update { settings in
                var settings = settings
                settings.hideInactiveAfterDays = value
                return settings
            }
        },
        updateHideUnread: { value in
            update { settings in
                var settings = settings
                settings.hideUnreadInactive = value
                return settings
            }
        },
        updateHideChannels: { value in
            update { settings in
                var settings = settings
                settings.hideChannels = value
                return settings
            }
        },
        updateGrayscale: { value in
            update { settings in
                var settings = settings
                settings.grayscale = value
                return settings
            }
        }
    )

    let signal = combineLatest(queue: .mainQueue(),
        context.sharedContext.presentationData,
        justgramSettings(accountManager: accountManager)
    )
    |> map { presentationData, settings -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text("Justgram"), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
        let listState = ItemListNodeState(presentationData: ItemListPresentationData(presentationData), entries: justgramSettingsEntries(presentationData: presentationData, settings: settings), style: .blocks, animateChanges: true)
        return (controllerState, (listState, arguments))
    }

    return ItemListController(context: context, state: signal)
}
