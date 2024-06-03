//
//  SessionService.swift
//  oChat
//
//  Created by Vitalii Sosin on 26.02.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SwiftUI
import SKAbstractions

public class SessionService: ISessionService {
  
  public var sessionDidExpireAction: (() -> Void)?
  
  // MARK: - Private properties
  
  private let secureStore: SecureDataManagerService
  private let lastActivityKey = Constants.sessionActivityKey
  private var sessionTimer: Timer?
  private var touchWindow: ITouchWindow?
  private var formatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = Constants.dateFormat
    return formatter
  }
  
  // MARK: - Init
  
  public init(secureStore: SecureDataManagerService) {
    self.secureStore = secureStore
    self.touchWindow = UIApplication.currentWindow as? ITouchWindow
  }
  
  // MARK: - Public properties
  
  public func startSession() {
    let now = Date()
    let dateString = formatter.string(from: now)
    secureStore.saveString(dateString, key: lastActivityKey)
    sessionTimer = Timer.scheduledTimer(withTimeInterval: Constants.timeInterval, repeats: false) { [weak self] _ in
      self?.sessionDidExpire()
    }
    
    touchWindow?.didSendEvent = { [weak self] _ in
      guard self?.sessionTimer != nil else {
        return
      }
      self?.updateLastActivityTime()
    }
  }
  
  public func isSessionActive() -> Bool {
    guard let dateString = secureStore.getString(for: lastActivityKey),
          let lastActivityTime = formatter.date(from: dateString) else {
      return false
    }
    return Date().timeIntervalSince(lastActivityTime) < Constants.timeInterval
  }
  
  public func updateLastActivityTime() {
    let now = Date()
    let dateString = formatter.string(from: now)
    secureStore.saveString(dateString, key: lastActivityKey)
    
    sessionTimer?.invalidate()
    sessionTimer = Timer.scheduledTimer(withTimeInterval: Constants.timeInterval, repeats: false) { [weak self] _ in
      self?.sessionDidExpire()
    }
  }
  
  public func sessionDidExpire() {
    sessionDidExpireAction?()
    secureStore.deleteData(for: lastActivityKey)
    sessionTimer?.invalidate()
    sessionTimer = nil
  }
}

// MARK: - Private

private extension SessionService {}

// MARK: - Constants

private enum Constants {
  static let sessionActivityKey = "SessionActivityKey"
  static let dateFormat = "yyyy-MM-dd HH:mm:ss"
  // Установка таймера на 10 минут
  static let timeInterval: CGFloat = 600
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
