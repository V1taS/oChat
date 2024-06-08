// Generated Localization File

import Foundation

public enum MessengerSDKStrings {
  public enum MessengerNewMessengeScreenLocalization {
    public static let stateButtonTitle = MessengerSDKStrings.tr(
      "MessengerNewMessengeScreenLocalization",
      "State.Button.Title"
    )
  }
  public enum MessengerListScreenModuleLocalization {
    public static let stateHeaderTitle = MessengerSDKStrings.tr(
      "MessengerListScreenModuleLocalization",
      "State.Header.Title"
    )
  }
  public enum MessengerDialogScreenLocalization {
    public static let stateHeaderTitle = MessengerSDKStrings.tr(
      "MessengerDialogScreenLocalization",
      "State.Notification.MessageFailure"
    )
  }
}

// MARK: - Implementation Details

extension MessengerSDKStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = MessengerSDKResources.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}
