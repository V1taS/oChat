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
import BackgroundTasks

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
    
    // TODO: - 🔴 Кажется из-за Background Task происходит таск, надо проверить
//    // Регистрация задачи Background Fetch
//    BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.sosinvitalii.oChat.refresh", using: nil) { task in
//      self.handleAppRefresh(task: task as? BGAppRefreshTask)
//    }
    
    window = TouchWindow(windowScene: windowScene)
    window?.makeKeyAndVisible()
    
    configurators().configure()
    rootCoordinator = RootCoordinator(services)
    rootCoordinator?.start()
    
#if DEBUG
    Wormholy.awake()
#endif
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
  
  // TODO: - 🔴 Кажется из-за Background Task происходит таск, надо проверить
//  func sceneDidEnterBackground(_ scene: UIScene) {
//    // Запланировать Background Fetch
//    scheduleAppRefresh()
//    
//    let application = UIApplication.shared
//    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
//    let didEnterBackgroundConfigurator = DidEnterBackgroundConfigurator(services: services)
//    
//    backgroundTask = application.beginBackgroundTask(withName: "ToxCoreBackgroundTask") {
//      application.endBackgroundTask(backgroundTask)
//      backgroundTask = .invalid
//    }
//    
//    DispatchQueue.global(qos: .background).async {
//      // Выполните задачу при входе в фон
//      self.handleAppRefresh(task: nil) // Явный вызов задачи
//      
//      didEnterBackgroundConfigurator.configure()
//      application.endBackgroundTask(backgroundTask)
//      backgroundTask = .invalid
//    }
//  }
}

// MARK: - Private

private extension SceneDelegate {
  // TODO: - 🔴 Кажется из-за Background Task происходит таск, надо проверить
//  func scheduleAppRefresh() {
//    let request = BGAppRefreshTaskRequest(identifier: "com.sosinvitalii.oChat.refresh")
//    request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 минут
//    
//    do {
//      try BGTaskScheduler.shared.submit(request)
//    } catch {
//      print("Не удалось запланировать фоновую задачу: \(error)")
//    }
//  }
//  
//  func handleAppRefresh(task: BGAppRefreshTask?) {
//    // Запланировать следующую задачу, если вызвано системой
//    if task != nil {
//      scheduleAppRefresh()
//    }
//    
//    // Выполнить вашу фоновую задачу
//    let didEnterBackgroundConfigurator = DidEnterBackgroundConfigurator(services: services)
//    
//    task?.expirationHandler = {
//      // Завершить задачу, если время истекло
//      task?.setTaskCompleted(success: false)
//    }
//    
//    DispatchQueue.global(qos: .background).async {
//      didEnterBackgroundConfigurator.configure()
//      
//      // Если task не равен nil, завершите задачу как успешную
//      if let task = task {
//        task.setTaskCompleted(success: true)
//      }
//    }
//  }
  
  func configurators() -> [Configurator] {
    return [
      FirstLaunchConfigurator(services: services),
      AppearanceConfigurator(services: services),
      BanScreenshotConfigurator(window: window)
    ]
  }
}
