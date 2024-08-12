//
//  SessionService.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 26.02.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SwiftUI
import SKAbstractions

public class SessionService: ISessionService {
  
  // MARK: - Singleton
  
  public static let shared = SessionService(secureStore: SecureDataManagerService(.session))
  
  public var sessionDidExpireAction: (() -> Void)?
  
  // MARK: - Private properties
  
  private let secureStore: SecureDataManagerService
  private let lastActivityKey = Constants.sessionActivityKey
  private var sessionTimer: Timer?
  private var touchWindow: ITouchWindow? = UIApplication.currentWindow as? ITouchWindow
  private var formatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = Constants.dateFormat
    return formatter
  }
  
  // MARK: - Init
  
  private init(secureStore: SecureDataManagerService) {
    self.secureStore = secureStore
  }
  
  // MARK: - Public methods
  
  public func startSession() {
    let now = Date()
    let dateString = formatter.string(from: now)
    secureStore.saveString(dateString, key: lastActivityKey)
    sessionTimer = Timer.scheduledTimer(
      withTimeInterval: Secrets.fiveMinutesAgoInSeconds,
      repeats: false
    ) { [weak self] _ in
      self?.sessionDidExpire()
      self?.sessionDidExpireAction?()
    }
    
    DispatchQueue.main.async { [weak self] in
      self?.touchWindow?.didSendEvent = { [weak self] _ in
        guard self?.sessionTimer != nil else {
          return
        }
        self?.updateLastActivityTime()
      }
    }
  }
  
  public func isSessionActive() -> Bool {
    guard let dateString = secureStore.getString(for: lastActivityKey),
          let lastActivityTime = formatter.date(from: dateString) else {
      return false
    }
    return Date().timeIntervalSince(lastActivityTime) < Secrets.fiveMinutesAgoInSeconds
  }
  
  public func updateLastActivityTime() {
    let now = Date()
    let dateString = formatter.string(from: now)
    secureStore.saveString(dateString, key: lastActivityKey)
    
    sessionTimer?.invalidate()
    sessionTimer = Timer.scheduledTimer(
      withTimeInterval: Secrets.fiveMinutesAgoInSeconds,
      repeats: false
    ) { [weak self] _ in
      self?.sessionDidExpire()
      self?.sessionDidExpireAction?()
    }
  }
  
  public func sessionDidExpire() {
    secureStore.deleteData(for: lastActivityKey)
    sessionTimer?.invalidate()
    sessionTimer = nil
  }
}

// MARK: - Constants

private enum Constants {
  static let sessionActivityKey = "SessionActivityKey"
  static let dateFormat = "yyyy-MM-dd HH:mm:ss"
}

// MARK: - UIApplication

private extension UIApplication {
  static var currentWindow: UIWindow? {
    return UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first(where: { $0.isKeyWindow })
  }
}
