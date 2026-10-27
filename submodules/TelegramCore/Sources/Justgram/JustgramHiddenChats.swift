// Justgram
import Foundation
import Postbox
import SwiftSignalKit

/// The single hiding rule shared by the chat list UI, the Postbox hidden set and the unread badge.
/// - Pinned chats are never hidden.
/// - Broadcast channels are hidden when `hideChannels` is on.
/// - Chats whose last activity is older than the cutoff are hidden, except unread non-muted ones unless `hideUnreadInactive` is on.
public func justgramShouldHideChat(peer: Peer?, index: ChatListIndex, isUnread: Bool, isMuted: Bool, settings: JustgramSettings, cutoff: Int32?) -> Bool {
    if index.pinningIndex != nil {
        return false
    }
    if settings.hideChannels, let channel = peer as? TelegramChannel, case .broadcast = channel.info {
        return true
    }
    if let cutoff, index.messageIndex.timestamp < cutoff {
        if settings.hideUnreadInactive {
            return true
        }
        return !(isUnread && !isMuted)
    }
    return false
}

func justgramHiddenChatPeerIds(transaction: Transaction, settings: JustgramSettings, now: Int32) -> Set<PeerId> {
    guard settings.isChatListFilterActive else {
        return Set()
    }
    let cutoff = settings.inactivityCutoff(now: now)
    let globalNotificationSettings = transaction.getGlobalNotificationSettings()

    var result = Set<PeerId>()
    for peerId in transaction.chatListGetAllPeerIds() {
        guard let (_, index) = transaction.getPeerChatListIndex(peerId) else {
            continue
        }
        if index.pinningIndex != nil {
            continue
        }
        let peer = transaction.getPeer(peerId)
        var isBroadcast = false
        if let channel = peer as? TelegramChannel, case .broadcast = channel.info {
            isBroadcast = true
        }
        let isOld = cutoff.flatMap { index.messageIndex.timestamp < $0 } ?? false
        if !(isOld || (settings.hideChannels && isBroadcast)) {
            continue
        }

        let readState = transaction.getCombinedPeerReadState(peerId)
        let isUnread = readState?.isUnread ?? false
        var isMuted = false
        if let peer {
            let notificationPeerId = peer.notificationSettingsPeerId ?? peer.id
            isMuted = resolvedIsRemovedFromTotalUnreadCount(globalSettings: globalNotificationSettings, peer: peer, peerSettings: transaction.getPeerNotificationSettings(id: notificationPeerId))
        }
        if justgramShouldHideChat(peer: peer, index: index, isUnread: isUnread, isMuted: isMuted, settings: settings, cutoff: cutoff) {
            result.insert(peerId)
        }
    }
    return result
}

/// Keeps Postbox's hidden chat set in sync with the Justgram rule, so chat list windows are filled
/// with visible chats only and paging keeps working.
public final class JustgramHiddenChats {
    private static var instances: [AccountRecordId: JustgramHiddenChats] = [:]

    public static func ensureStarted(account: Account, settings: Signal<JustgramSettings, NoError>, foreground: Signal<Bool, NoError>) {
        assert(Queue.mainQueue().isCurrent())
        if instances[account.id] != nil {
            return
        }
        instances[account.id] = JustgramHiddenChats(account: account, settings: settings, foreground: foreground)
    }

    public static func requestRefresh(account: Account) {
        Queue.mainQueue().async {
            instances[account.id]?.requestRefresh()
        }
    }

    private let refreshCounter = ValuePromise<Int>(0, ignoreRepeated: true)
    private var refreshCounterValue = 0
    private let disposable = MetaDisposable()
    private var currentHiddenPeerIds = Set<PeerId>()
    private var hiddenDisposable: Disposable?

    private init(account: Account, settings: Signal<JustgramSettings, NoError>, foreground: Signal<Bool, NoError>) {
        let unreadChanges = account.postbox.combinedView(keys: [.unreadCounts(items: [.totalInGroup(.root), .totalInGroup(Namespaces.PeerGroup.archive)])])
        |> map { _ -> Void in
            return Void()
        }

        let postbox = account.postbox
        self.disposable.set((combineLatest(
            settings,
            justgramClock(foreground: foreground),
            unreadChanges,
            self.refreshCounter.get()
        )
        |> mapToThrottled { settings, now, _, _ -> Signal<Set<PeerId>, NoError> in
            if !settings.isChatListFilterActive {
                return .single(Set())
            }
            return postbox.transaction { transaction -> Set<PeerId> in
                return justgramHiddenChatPeerIds(transaction: transaction, settings: settings, now: now)
            }
        }
        |> deliverOnMainQueue).start(next: { [weak self, weak postbox] peerIds in
            guard let self, let postbox else {
                return
            }
            self.apply(peerIds: peerIds, postbox: postbox)
        }))
    }

    deinit {
        self.disposable.dispose()
        self.hiddenDisposable?.dispose()
    }

    private func requestRefresh() {
        self.refreshCounterValue += 1
        self.refreshCounter.set(self.refreshCounterValue)
    }

    private func apply(peerIds: Set<PeerId>, postbox: Postbox) {
        if peerIds == self.currentHiddenPeerIds {
            return
        }
        self.currentHiddenPeerIds = peerIds

        // Add the new set before releasing the previous one, so unchanged chats never flicker.
        let previousDisposable = self.hiddenDisposable
        if peerIds.isEmpty {
            self.hiddenDisposable = nil
        } else {
            self.hiddenDisposable = postbox.addHiddenChatIds(peerIds: Array(peerIds))
        }
        previousDisposable?.dispose()
    }
}
