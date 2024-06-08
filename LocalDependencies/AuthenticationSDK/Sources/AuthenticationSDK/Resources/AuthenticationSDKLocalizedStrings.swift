// Generated Localization File

import Foundation

public enum AuthenticationSDKStrings {
  public enum AuthenticationScreenLocalization {
    public static let stateEnterPasscodeTitle = AuthenticationSDKStrings.tr(
      "AuthenticationScreenLocalization",
      "State.EnterPasscode.Title"
    )
    
    public static let stateEnterOldPasscodeTitle = AuthenticationSDKStrings.tr(
      "AuthenticationScreenLocalization",
      "State.EnterOldPasscode.Title"
    )
    
    public static let stateReEnterPasscodeTitle = AuthenticationSDKStrings.tr(
      "AuthenticationScreenLocalization",
      "State.ReEnterPasscode.Title"
    )
    
    public static let stateLoginPasscodeTitle = AuthenticationSDKStrings.tr(
      "AuthenticationScreenLocalization",
      "State.LoginPasscode.Title"
    )
    
    public static let stateCreatePasscodeSuccessTitle = AuthenticationSDKStrings.tr(
      "AuthenticationScreenLocalization",
      "State.CreatePasscode.Success.Title"
    )
    
    public static let stateCreatePasscodeFailureTitle = AuthenticationSDKStrings.tr(
      "AuthenticationScreenLocalization",
      "State.CreatePasscode.Failure.Title"
    )
    
    public static let stateLoginPasscodeSuccessTitle = AuthenticationSDKStrings.tr(
      "AuthenticationScreenLocalization",
      "State.LoginPasscode.Success.Title"
    )
    
    public static let stateLoginPasscodeFailureTitle = AuthenticationSDKStrings.tr(
      "AuthenticationScreenLocalization",
      "State.LoginPasscode.Failure.Title"
    )
    
    public static let stateValidationCountFailureTitle = AuthenticationSDKStrings.tr(
      "AuthenticationScreenLocalization",
      "State.ValidationCount.Failure.Title"
    )
    
    public static let stateSimplePasswordsFailureTitle = AuthenticationSDKStrings.tr(
      "AuthenticationScreenLocalization",
      "State.SimplePasswords.Failure.Title"
    )
  }
  
  public enum ValidationCount {
    public enum Failure {
      /// The access code must consist of %@ digits
      public static func title(_ p1: Any) -> String {
        return tr("AuthenticationScreenLocalization", "State.ValidationCount.Failure.Title",String(describing: p1))
      }
    }
  }
}

// MARK: - Implementation Details

extension AuthenticationSDKStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = AuthenticationSDKResources.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}
