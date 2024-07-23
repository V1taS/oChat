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

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  // MARK: - Internal properties
  
  var window: UIWindow?
  
  // MARK: - Private properties
  
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
}

// MARK: - Private

private extension SceneDelegate {
  func configurators() -> [Configurator] {
    return [
      FirstLaunchConfigurator(services: services),
      AppearanceConfigurator(services: services),
      ConfigurationValueConfigurator(services: services),
      BanScreenshotConfigurator(window: window)
    ]
  }
}
