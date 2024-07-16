//
//  AppDelegate.swift
//  oChat
//
//  Created by Vitalii Sosin on 12.04.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import UIKit
import SKServices
import AVFAudio

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
  
  private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
  private var audioPlayer: AVAudioPlayer?
  
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    // Проверка, был ли запуск из-за нажатия на уведомление
    if let notificationOption = launchOptions?[.remoteNotification] as? [String: AnyObject] {
      handleNotification(notificationOption)
    }
    
    // FIXME: - Делаем приложение постоянно активным (Аппл не пропустит такой хак, надо будет подумать)
    // Настройка аудиосессии для работы в фоне
    let audioSession = AVAudioSession.sharedInstance()
    do {
      try audioSession.setCategory(.playback, mode: .default)
      try audioSession.setActive(true)
    } catch {
      print("Failed to set up audio session")
    }
    
    // Запуск пустого аудиоплеера для работы в фоне
    if let audioFilePath = Bundle.main.path(forResource: "silence", ofType: "mp3") {
      let audioFileURL = URL(fileURLWithPath: audioFilePath)
      do {
        audioPlayer = try AVAudioPlayer(contentsOf: audioFileURL)
        audioPlayer?.numberOfLoops = -1 // Бесконечный цикл
        audioPlayer?.play()
      } catch {
        print("Failed to play audio")
      }
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
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    let token = tokenParts.joined()
    MessengerService.shared.modelSettingsManager.saveMyPushNotificationToken(token, completion: {})
  }
  
  /// Этот метод вызывается, если регистрация устройства для удалённых уведомлений не удалась.
  /// - Parameters:
  ///   - application: Текущее приложение.
  ///   - error: Ошибка, возникшая при попытке регистрации.
  func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("❌ Fail to register: \(error)")
  }
  
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
    if let toxAddress = userInfo["toxAddress"] as? String {
      MessengerService.shared.appSettingsManager.setIsNewMessagesAvailable(
        true,
        toxAddress: toxAddress,
        completion: {}
      )
      
      DispatchQueue.global().async {
        MessengerService.shared.modelHandlerService.getContactModels { contactModels in
          DispatchQueue.main.async {
            if let contactIndex = contactModels.firstIndex(where: { $0.toxAddress == toxAddress }) {
              var updatedContact = contactModels[contactIndex]
              if updatedContact.messenges.last?.messageType != .systemSuccess {
                updatedContact.messenges.append(
                  .init(
                    messageType: .systemSuccess,
                    messageStatus: .sent,
                    message: "Вы получили приглашение на общение. Присоединитесь и начните общение.",
                    replyMessageText: nil,
                    images: [],
                    videos: [],
                    recording: nil
                  )
                )
                MessengerService.shared.modelHandlerService.saveContactModel(updatedContact, completion: {})
              }
            }
          }
        }
      }
    }
  }
}

// MARK: - Endless cycle in background

extension AppDelegate {
  func applicationDidEnterBackground(_ application: UIApplication) {
    startBackgroundTask()
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    endBackgroundTask()
  }
  
  func startBackgroundTask() {
    backgroundTask = UIApplication.shared.beginBackgroundTask {
      self.endBackgroundTask()
    }
    assert(backgroundTask != .invalid)
  }
  
  func endBackgroundTask() {
    UIApplication.shared.endBackgroundTask(backgroundTask)
    backgroundTask = .invalid
  }
}
