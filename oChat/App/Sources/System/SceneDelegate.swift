//
//  SceneDelegate.swift
//  oChat
//
//  Created by Vitalii Sosin on 12.04.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import UIKit
import SKUIKit
import SKAbstractions
import Wormholy
import SKServices
import SwiftUI
import ToxCore

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  // MARK: - Internal properties
  
  var window: UIWindow?
  
  // MARK: - Private properties
  
  private let brandingStubView = UIHostingController(rootView: BrandingStubView()).view
  private let services: IApplicationServices = ApplicationServices()
  private var rootCoordinator: RootCoordinator?
  
  // MARK: - Internal func
  
  func application(
    _ application: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
    sceneConfig.delegateClass = SceneDelegate.self
    return sceneConfig
  }
  
  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene else { return }
    window = TouchWindow(windowScene: windowScene)
    window?.makeKeyAndVisible()
    
    configurators().configure()
    rootCoordinator = RootCoordinator(services)
    rootCoordinator?.start()
    
    // #if DEBUG
#warning("Необходимо включить дебаг перед публикацией в стор")
    Wormholy.awake()
    // #endif
  }
  
  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    if let url = URLContexts.first?.url {
      Task {
        await services.userInterfaceAndExperienceService.deepLinkService.saveDeepLinkURL(url)
      }
    }
  }
  
  func sceneWillEnterForeground(_ scene: UIScene) {
    brandingStubView?.removeFromSuperview()
  }
  
  func sceneWillResignActive(_ scene: UIScene) {
    guard let window,
          let brandingStubView else {
      return
    }
    
    if !brandingStubView.isDescendant(of: window) {
      brandingStubView.frame = window.bounds
      window.addSubview(brandingStubView)
    }
  }
  
  func sceneDidBecomeActive(_ scene: UIScene) {
    brandingStubView?.removeFromSuperview()
    ConfigurationValueConfigurator(services: services).configure()
  }
  
  // TODO: - 🔴 сделать работу в фоне
  
  func sceneDidEnterBackground(_ scene: UIScene) {
    let application = UIApplication.shared
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    backgroundTask = application.beginBackgroundTask(withName: "ToxCoreBackgroundTask") {
      application.endBackgroundTask(backgroundTask)
      backgroundTask = .invalid
    }
    
    DispatchQueue.global(qos: .background).async {
      self.keepToxCoreActive()
      
      application.endBackgroundTask(backgroundTask)
      backgroundTask = .invalid
    }
  }
  
  // TODO: - 🔴 сделать работу в фоне
  func keepToxCoreActive() {
    // Код для поддержания активности ToxCore
    ToxCore.shared.setMessageCallback { [weak self] friendId, jsonString in
      DispatchQueue.main.async {
        self?.updateDidReceiveMessage(jsonString: jsonString, friendId: friendId)
      }
    }
  }
}

// MARK: - Private

private extension SceneDelegate {
  func configurators() -> [Configurator] {
    return [
      FirstLaunchConfigurator(services: services),
      AppearanceConfigurator(services: services),
      BanScreenshotConfigurator(window: window)
    ]
  }
  
  // TODO: - 🔴 сделать работу в фоне
  func sendLocalNotificationIfNeeded(contactModel: ContactModel) {
    // Проверка, находится ли приложение в фоне
    DispatchQueue.main.async { [weak self] in
      if UIApplication.shared.applicationState == .background {
        self?.sendLocalNotification(contactModel: contactModel)
      }
    }
  }
  
  // TODO: - 🔴 сделать работу в фоне
  func sendLocalNotification(contactModel: ContactModel) {
    let address: String = "\(contactModel.toxAddress?.formatString(minTextLength: 10) ?? "unknown")"
    let content = UNMutableNotificationContent()
    content.title = OChatStrings.MessengerListScreenModuleLocalization
      .LocalNotification.title
    content.body = "\(OChatStrings.MessengerListScreenModuleLocalization.LocalNotification.body) \(address)."
    content.sound = UNNotificationSound.default
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    
    UNUserNotificationCenter.current().add(request) { _ in }
  }
  
  // TODO: - 🔴 сделать работу в фоне
  func updateDidReceiveMessage(jsonString: String?, friendId: Int32) {
    guard let jsonString,
          let jsonData = jsonString.data(using: .utf8),
          let model = try? JSONDecoder().decode(MessengerNetworkRequestDTO.self, from: jsonData).mapToModel() else {
      return
    }
    handleMessageReceived(model, friendId)
  }
  
  // TODO: - 🔴 сделать работу в фоне
  func handleMessageReceived(_ messageModel: MessengerNetworkRequestModel, _ toxFriendId: Int32) {
    //    Task { [weak self] in
    //      guard let self else { return }
    //
    //
    //      let contactModels = await interactor.getContactModels()
    //      updateRedDotToTabBar(contactModels: contactModels)
    //      let messageText = await interactor.decrypt(messageModel.messageText) ?? ""
    //      let pushNotificationToken = await interactor.decrypt(messageModel.senderPushNotificationToken)
    //
    //      if let contact = factory.searchContact(
    //        contactModels: contactModels,
    //        torAddress: messageModel.senderAddress
    //      ) {
    //        let updatedContact = factory.updateExistingContact(
    //          contact: contact,
    //          messageModel: messageModel,
    //          pushNotificationToken: pushNotificationToken
    //        )
    //
    //        let messengeModel = factory.addMessageToContact(
    //          message: messageText,
    //          messageType: .received,
    //          replyMessageText: messageModel.replyMessageText,
    //          images: [],
    //          videos: [],
    //          recording: nil
    //        )
    //
    //        await interactor.addMessenge(contact.id, messengeModel)
    //        await interactor.saveContactModel(updatedContact)
    //        await updateListContacts()
    //        moduleOutput?.dataModelHasBeenUpdated()
    //        await impactFeedback.impactOccurred()
    //        sendLocalNotificationIfNeeded(contactModel: updatedContact)
    //        messengeDictionaryModels = await interactor.getDictionaryMessengeModels()
    //      } else {
    //        let newContact = factory.createNewContact(
    //          messageModel: messageModel,
    //          pushNotificationToken: pushNotificationToken,
    //          status: .online
    //        )
    //        await interactor.saveContactModel(newContact)
    //        await updateListContacts()
    //        moduleOutput?.dataModelHasBeenUpdated()
    //        await impactFeedback.impactOccurred()
    //        sendLocalNotificationIfNeeded(contactModel: newContact)
    //        messengeDictionaryModels = await interactor.getDictionaryMessengeModels()
    //      }
    //    }
  }
}
