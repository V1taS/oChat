// Generated Localization File

import Foundation

public enum AbstractionsStrings {
  public enum SKAbstractionsLocalization {
    public static let commonStatusTitleOnline = AbstractionsStrings.tr(
      "SKAbstractionsLocalization",
      "Common.Status.Title.Online"
    )
    public static let commonStatusTitleOffline = AbstractionsStrings.tr(
      "SKAbstractionsLocalization",
      "Common.Status.Title.Offline"
    )
    public static let messengerModelStatusTitleConnecting = AbstractionsStrings.tr(
      "SKAbstractionsLocalization",
      "MessengerModel.Status.Title.Connecting"
    )
    public static let contactModelStatusTitleConversationRequest = AbstractionsStrings.tr(
      "SKAbstractionsLocalization",
      "ContactModel.Status.Title.ConversationRequest"
    )
    public static let contactModelStatusTitleSentRequest = AbstractionsStrings.tr(
      "SKAbstractionsLocalization",
      "ContactModel.Status.Title.SentRequest"
    )
  }
}

// MARK: - Implementation Details

extension AbstractionsStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = SKAbstractionsResources.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}
