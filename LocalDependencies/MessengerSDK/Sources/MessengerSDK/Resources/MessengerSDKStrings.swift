// Generated Localization File

import Foundation

public enum MessengerSDKStrings {
  public enum MessengerListScreenModuleLocalization {
    public static let stateHeaderTitle = MessengerSDKStrings.tr(
      "MessengerListScreenModuleLocalization",
      "State.Header.Title"
    )
    public static let stateNotificationPasscodeNotSetTitle = MessengerSDKStrings.tr(
      "MessengerListScreenModuleLocalization",
      "State.Notification.PasscodeNotSet.Title"
    )
    public static let stateBannerPushNotificationTitle = MessengerSDKStrings.tr(
      "MessengerListScreenModuleLocalization",
      "State.Banner.PushNotification.Title"
    )
  }
  public enum MessengerDialogScreenLocalization {
    public static let stateNotificationFailureTitle = MessengerSDKStrings.tr(
      "MessengerDialogScreenLocalization",
      "State.Notification.MessageFailure"
    )
    public static let stateInitialMessengerHeaderTitle = MessengerSDKStrings.tr(
      "MessengerDialogScreenLocalization",
      "Messenger.Initial.Header.Title"
    )
    public static let stateInitialMessengerHeaderDescription = MessengerSDKStrings.tr(
      "MessengerDialogScreenLocalization",
      "Messenger.Initial.Header.Description"
    )
    public static let stateInitialButtonTitle = MessengerSDKStrings.tr(
      "MessengerDialogScreenLocalization",
      "Messenger.Initial.Button.Title"
    )
    public static let stateInitialMessengerOneTitle = MessengerSDKStrings.tr(
      "MessengerDialogScreenLocalization",
      "Messenger.Initial.One.Title"
    )
    public static let stateInitialMessengerOneDescription = MessengerSDKStrings.tr(
      "MessengerDialogScreenLocalization",
      "Messenger.Initial.One.Description"
    )
    public static let stateInitialMessengerTwoTitle = MessengerSDKStrings.tr(
      "MessengerDialogScreenLocalization",
      "Messenger.Initial.Two.Title"
    )
    public static let stateInitialMessengerTwoDescription = MessengerSDKStrings.tr(
      "MessengerDialogScreenLocalization",
      "Messenger.Initial.Two.Description"
    )
    public static let stateInitialMessengerThreeTitle = MessengerSDKStrings.tr(
      "MessengerDialogScreenLocalization",
      "Messenger.Initial.Three.Title"
    )
    public static let stateInitialMessengerThreeDescription = MessengerSDKStrings.tr(
      "MessengerDialogScreenLocalization",
      "Messenger.Initial.Three.Description"
    )
    public static let stateInitialMessengerNote = MessengerSDKStrings.tr(
      "MessengerDialogScreenLocalization",
      "Messenger.Initial.Note"
    )
    
    public static let stateRequestMessengerHeaderTitle = MessengerSDKStrings.tr(
      "MessengerDialogScreenLocalization",
      "Messenger.Request.Header.Title"
    )
    public static let stateRequestMessengerHeaderDescription = MessengerSDKStrings.tr(
      "MessengerDialogScreenLocalization",
      "Messenger.Request.Header.Description"
    )
    public static let stateRequestButtonTitle = MessengerSDKStrings.tr(
      "MessengerDialogScreenLocalization",
      "Messenger.Request.Button.Title"
    )
    public static let stateRequestButtonCancelTitle = MessengerSDKStrings.tr(
      "MessengerDialogScreenLocalization",
      "Messenger.Request.Button.Cancel.Title"
    )
    public static let stateRequestMessengerOneTitle = MessengerSDKStrings.tr(
      "MessengerDialogScreenLocalization",
      "Messenger.Request.One.Title"
    )
    public static let stateRequestMessengerOneDescription = MessengerSDKStrings.tr(
      "MessengerDialogScreenLocalization",
      "Messenger.Request.One.Description"
    )
    public static let stateRequestMessengerTwoTitle = MessengerSDKStrings.tr(
      "MessengerDialogScreenLocalization",
      "Messenger.Request.Two.Title"
    )
    public static let stateRequestMessengerTwoDescription = MessengerSDKStrings.tr(
      "MessengerDialogScreenLocalization",
      "Messenger.Request.Two.Description"
    )
    public static let stateRequestMessengerThreeTitle = MessengerSDKStrings.tr(
      "MessengerDialogScreenLocalization",
      "Messenger.Request.Three.Title"
    )
    public static let stateRequestMessengerThreeDescription = MessengerSDKStrings.tr(
      "MessengerDialogScreenLocalization",
      "Messenger.Request.Three.Description"
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
