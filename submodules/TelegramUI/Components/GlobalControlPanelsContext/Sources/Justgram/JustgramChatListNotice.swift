// Justgram
import Foundation
import TelegramCore

/// Keeps only security-related banners above the chat list.
func justgramFilterChatListNotice(_ notice: GlobalControlPanelsContext.ChatListNotice?) -> GlobalControlPanelsContext.ChatListNotice? {
    guard justgramPromosDisabled, let notice else {
        return notice
    }
    switch notice {
    case .reviewLogin, .setupPassword, .accountFreeze:
        return notice
    default:
        return nil
    }
}
