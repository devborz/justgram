// Justgram
import Foundation
import Postbox
import SwiftSignalKit

private func justgramSummaryTag(peer: Peer, isContact: Bool) -> PeerSummaryCounterTags {
    // Mirrors peerSummaryCounterTags in SyncCore_StandaloneAccountTransaction.swift
    if let user = peer as? TelegramUser {
        if user.botInfo != nil {
            return .bot
        } else if isContact {
            return .contact
        } else {
            return .nonContact
        }
    } else if peer is TelegramGroup {
        return .group
    } else if let channel = peer as? TelegramChannel {
        switch channel.info {
        case .broadcast:
            return .channel
        case .group:
            return .group
        }
    } else {
        return .nonContact
    }
}

/// Unread count of chats hidden by Justgram that the stock badge would otherwise include.
private func justgramHiddenUnreadCount(transaction: Transaction, settings: JustgramSettings, category: ChatListTotalUnreadStateCategory, statsType: ChatListTotalUnreadStateStats, includeTags: PeerSummaryCounterTags, now: Int32) -> Int32 {
    guard settings.isChatListFilterActive else {
        return 0
    }
    let cutoff = settings.inactivityCutoff(now: now)
    let globalNotificationSettings = transaction.getGlobalNotificationSettings()

    var result: Int32 = 0
    for peerId in transaction.getUnreadChatListPeerIds(groupId: .root, filterPredicate: nil, additionalFilter: nil, stopOnFirstMatch: false) {
        guard let (groupId, index) = transaction.getPeerChatListIndex(peerId), groupId == .root, let peer = transaction.getPeer(peerId) else {
            continue
        }
        guard let readState = transaction.getCombinedPeerReadState(peerId), readState.isUnread else {
            continue
        }
        let notificationPeerId = peer.notificationSettingsPeerId ?? peer.id
        let isMuted = resolvedIsRemovedFromTotalUnreadCount(globalSettings: globalNotificationSettings, peer: peer, peerSettings: transaction.getPeerNotificationSettings(id: notificationPeerId))
        if !justgramShouldHideChat(peer: peer, index: index, isUnread: true, isMuted: isMuted, settings: settings, cutoff: cutoff) {
            continue
        }
        // The badge uses filtered counters, which already exclude muted chats.
        if isMuted && category == .filtered {
            continue
        }
        let tag = justgramSummaryTag(peer: peer, isContact: transaction.isPeerContact(peerId: notificationPeerId))
        if !includeTags.contains(tag) {
            continue
        }
        switch statsType {
        case .chats:
            result += 1
        case .messages:
            result += max(readState.count, readState.markedUnread ? 1 : 0)
        }
    }
    return result
}


/// Unread count of root chats hidden by Justgram, counted the way the badge counts them.
public func justgramHiddenUnreadCount(engine: TelegramEngine, settings: JustgramSettings, category: EngineChatListTotalUnreadStateCategory, statsType: EngineChatListTotalUnreadStateStats, includeTags: EnginePeerSummaryCounterTags, now: Int32) -> Signal<Int32, NoError> {
    return engine.account.postbox.transaction { transaction -> Int32 in
        return justgramHiddenUnreadCount(transaction: transaction, settings: settings, category: category, statsType: statsType, includeTags: includeTags, now: now)
    }
}
