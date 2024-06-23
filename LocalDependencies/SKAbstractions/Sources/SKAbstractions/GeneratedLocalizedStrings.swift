// Generated Localization File

import Foundation

public enum AbstractionsStrings {
  public enum SKAbstractionsLocalization {
    public static let messengerModelStatusTitleOnline = AbstractionsStrings.tr(
      "SKAbstractionsLocalization",
      "MessengerModel.Status.Title.Online"
    )
    public static let messengerModelStatusTitleOffline = AbstractionsStrings.tr(
      "SKAbstractionsLocalization",
      "MessengerModel.Status.Title.Offline"
    )
    public static let messengerModelStatusTitleConnecting = AbstractionsStrings.tr(
      "SKAbstractionsLocalization",
      "MessengerModel.Status.Title.Connecting"
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
