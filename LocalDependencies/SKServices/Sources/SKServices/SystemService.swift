//
//  SystemService.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 26.02.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SwiftUI
import SKAbstractions
import SafariServices
import LocalAuthentication

// MARK: - System Service

public final class SystemService: ISystemService {
  public init() {}
  
  public func openSettings() {
    openSettings(completion: { _ in })
  }
  
  public func openSettings(completion: @escaping (Result<Void, SystemServiceError>) -> Void) {
    guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
      DispatchQueue.main.async {
        completion(.failure(.unableToCreateURL))
      }
      return
    }
    
    UIApplication.shared.open(settingsURL) { success in
      if success {
        DispatchQueue.main.async {
          completion(.success(()))
        }
      } else {
        DispatchQueue.main.async {
          completion(.failure(.failedToOpenURL))
        }
      }
    }
  }
  
  public func copyToClipboard(text: String) {
    copyToClipboard(text: text, completion: { _ in })
  }
  
  public func copyToClipboard(text: String, completion: @escaping (Result<Void, SystemServiceError>) -> Void) {
    UIPasteboard.general.string = text
    DispatchQueue.main.async {
      if UIPasteboard.general.string == text {
        completion(.success(()))
      } else {
        completion(.failure(.failedToCopyToClipboard))
      }
    }
  }
  
  public func openURLInSafari(
    urlString: String,
    completion: @escaping (Result<Void, SKAbstractions.SystemServiceError>
    ) -> Void) {
    guard let url = URL(string: urlString) else {
      DispatchQueue.main.async {
        completion(.failure(.unableToCreateURL))
      }
      return
    }
    
    let safariViewController = SFSafariViewController(url: url)
    
    if let topController = UIViewController.topController {
      DispatchQueue.main.async {
        topController.present(safariViewController, animated: true) {
          completion(.success(()))
        }
      }
    } else {
      DispatchQueue.main.async {
        completion(.failure(.failedToOpenURL))
      }
    }
  }
  
  public func openURLInSafari(urlString: String) {
    openURLInSafari(urlString: urlString, completion: { _ in })
  }
  
  public func getCurrentLanguage() -> AppLanguageType {
    let preferredLanguage = Locale.preferredLanguages.first?.prefix(2) ?? "en"
    return AppLanguageType(rawValue: String(preferredLanguage)) ?? .english
  }
  
  public func getDeviceModel() -> String {
    return UIDevice.current.model
  }
  
  public func getSystemName() -> String {
    return UIDevice.current.systemName
  }
  
  public func getSystemVersion() -> String {
    return UIDevice.current.systemVersion
  }
  
  public func getDeviceIdentifier() -> String {
    return UIDevice.current.identifierForVendor?.uuidString ?? "Unknown"
  }
  
  public func getAppVersion() -> String {
    guard let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
      return "Unknown"
    }
    return version
  }
  
  public func getAppBuildNumber() -> String {
    guard let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String else {
      return "Unknown"
    }
    return build
  }
  
  public func checkIfPasscodeIsSet(completion: ((Result<Void, SystemServiceError>) -> Void)?) {
    let context = LAContext()
    var error: NSError?
    let isPasscodeSet = context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
    
    if let laError = error, laError.code == kLAErrorPasscodeNotSet {
      completion?(.failure(.passcodeNotSet))
      return
    }
    
    if !isPasscodeSet {
      completion?(.failure(.passcodeNotSet))
      return
    }
    completion?(.success(()))
  }
}

// MARK: - UIApplication

private extension UIApplication {
  /// Возвращает текущее активное окно приложения.
  static var currentWindow: UIWindow? {
    return UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first(where: { $0.isKeyWindow })
  }
}


// MARK: - Navigation

private extension UIViewController {
  /// Возвращает самый верхний контроллер в иерархии модальных представлений.
  static var topController: UIViewController? {
    var topController: UIViewController? = UIApplication.currentWindow?.rootViewController
    while let presentedViewController = topController?.presentedViewController {
      topController = presentedViewController
    }
    return topController
  }
}

// MARK: - Private

private extension SystemService {}