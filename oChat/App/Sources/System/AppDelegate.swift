//
//  AppDelegate.swift
//  oChat
//
//  Created by Vitalii Sosin on 12.04.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import UIKit
import SKServices

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
  
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    // Проверка, был ли запуск из-за нажатия на уведомление
    if let notificationOption = launchOptions?[.remoteNotification] as? [String: AnyObject] {
      handleNotification(notificationOption)
    }
    return true
  }
  
  // MARK: UISceneSession Lifecycle
  
  func application(
    _ application: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    let sceneConfig: UISceneConfiguration = UISceneConfiguration(
      name: nil,
      sessionRole: connectingSceneSession.role
    )
    sceneConfig.delegateClass = SceneDelegate.self
    return sceneConfig
  }
  
  func application(
    _ application: UIApplication,
    didDiscardSceneSessions sceneSessions: Set<UISceneSession>
  ) {}
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
  /// Этот метод вызывается после успешной регистрации устройства для удалённых уведомлений.
  /// - Parameters:
  ///   - application: Текущее приложение.
  ///   - deviceToken: Токен устройства, используемый для отправки уведомлений.
  func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Task {
      let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
      let token = tokenParts.joined()
      await AppSettingsDataManager.shared.saveMyPushNotificationToken(token)
    }
  }
  
  /// Этот метод вызывается, если регистрация устройства для удалённых уведомлений не удалась.
  /// - Parameters:
  ///   - application: Текущее приложение.
  ///   - error: Ошибка, возникшая при попытке регистрации.
  func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {}
  
  /// Этот метод вызывается, когда уведомление поступает и приложение находится на переднем плане.
  /// - Parameters:
  ///   - center: Центр уведомлений.
  ///   - notification: Уведомление, которое поступило.
  ///   - completionHandler: Блок завершения, вызываемый для указания как обрабатывать уведомление.
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    // Определяет, как уведомление будет представлено, когда приложение активно
    completionHandler([.banner, .list, .sound])
  }
  
  /// Этот метод вызывается, когда пользователь взаимодействует с уведомлением (например, нажимает на него).
  /// - Parameters:
  ///   - center: Центр уведомлений.
  ///   - response: Ответ пользователя на уведомление.
  ///   - completionHandler: Блок завершения, вызываемый после обработки уведомления.
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo
    handleNotification(userInfo)
    completionHandler()
  }
  
  /// Обработка данных уведомления
  /// - Parameter userInfo: Данные, полученные из уведомления
  func handleNotification(_ userInfo: [AnyHashable: Any]) {
    Task {
      if let toxAddress = userInfo["toxAddress"] as? String,
         let contactID = userInfo["contactID"] as? String {
        await ContactsDataManager.shared.setIsNewMessagesAvailable(
          true,
          id: contactID
        )
        
        await MessengeDataManager.shared.addMessenge(
          contactID,
          .init(
            messageType: .systemSuccess,
            messageStatus: .sent,
            message: OChatStrings.CommonStrings.Notification
              .AppDelegate.Received.title,
            replyMessageText: nil,
            images: [],
            videos: [],
            recording: nil
          )
        )
      }
    }
  }
}
