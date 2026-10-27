// Justgram
import Foundation
import SwiftSignalKit
import TelegramCore
import AccountContext

struct JustgramChatListFilter: Equatable {
    static let inactive = JustgramChatListFilter(settings: .defaultSettings, cutoff: nil)

    var settings: JustgramSettings
    var cutoff: Int32?

    var isActive: Bool {
        return self.settings.isChatListFilterActive
    }

    func hides(_ entry: ChatListNodeEntry.PeerEntryData) -> Bool {
        guard self.isActive, entry.promoInfo == nil, case let .chatList(index) = entry.index else {
            return false
        }
        return justgramShouldHideChat(
            peer: entry.peer.chatMainPeer?._asPeer(),
            index: index,
            isUnread: entry.readState?.isUnread ?? false,
            isMuted: entry.isRemovedFromTotalUnreadCount,
            settings: self.settings,
            cutoff: self.cutoff
        )
    }

    /// When even unread chats are hidden, everything below the cutoff is hidden, so a hole there never needs a loading row.
    func hidesHole(_ index: EngineMessage.Index) -> Bool {
        if self.settings.hideUnreadInactive, let cutoff = self.cutoff {
            return index.timestamp < cutoff
        } else {
            return false
        }
    }

    /// The list is sorted by activity: once the oldest loaded chat is past the cutoff and nothing there can be visible, stop paging.
    func effectiveHasEarlier(_ list: EngineChatList) -> Bool {
        guard list.hasEarlier else {
            return false
        }
        if self.settings.hideUnreadInactive, let cutoff = self.cutoff, let first = list.items.first, case let .chatList(index) = first.index, index.pinningIndex == nil, index.messageIndex.timestamp < cutoff {
            return false
        }
        return true
    }

    func pagingCount(_ view: ChatListNodeView) -> Int {
        return self.isActive ? view.filteredEntries.count : view.originalList.items.count
    }
}

func justgramChatListFilter(context: AccountContext, location: ChatListControllerLocation, mode: ChatListNodeMode) -> Signal<JustgramChatListFilter, NoError> {
    guard case .chatList = mode, case .chatList = location else {
        return .single(.inactive)
    }
    return combineLatest(
        justgramSettings(accountManager: context.sharedContext.accountManager),
        justgramClock(foreground: context.sharedContext.applicationBindings.applicationInForeground)
    )
    |> map { settings, now -> JustgramChatListFilter in
        return JustgramChatListFilter(settings: settings, cutoff: settings.inactivityCutoff(now: now))
    }
    |> distinctUntilChanged
}

func justgramStartHiddenChats(context: AccountContext) {
    JustgramHiddenChats.ensureStarted(
        account: context.account,
        settings: justgramSettings(accountManager: context.sharedContext.accountManager),
        foreground: context.sharedContext.applicationBindings.applicationInForeground
    )
}
