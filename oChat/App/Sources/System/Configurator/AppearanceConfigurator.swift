//
//  AppearanceConfigurator.swift
//  oChat
//
//  Created by Vitalii Sosin on 17.04.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SKAbstractions
import SKUIKit
import UIKit
import SKStyle

struct AppearanceConfigurator: Configurator {
  
  // MARK: - Private properties
  
  private let services: IApplicationServices
  private let textAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.fancy.text.regularMedium]
  
  // MARK: - Init
  
  init(services: IApplicationServices) {
    self.services = services
  }
  
  // MARK: - Internal func
  
  func configure() {
    setupApplicationTheme()
    setupTabBarAppearance()
    setupNavigationBarAppearance()
    setupBarButtonItemAppearance()
  }
}

// MARK: - Private

private extension AppearanceConfigurator {
  func setupApplicationTheme() {
    let colorScheme = services.userInterfaceAndExperienceService.uiService.getColorScheme() ?? .unspecified
    UIApplication.currentWindow?.overrideUserInterfaceStyle = colorScheme
  }
  
  func setupTabBarAppearance() {
    UITabBar.appearance().tintColor = SKStyleAsset.azure.color
    UITabBar.appearance().unselectedItemTintColor = SKStyleAsset.constantSlate.color
    UITabBar.appearance().backgroundColor = SKStyleAsset.onyx.color.withAlphaComponent(0.99)
    UITabBar.appearance().backgroundImage = UIImage()
    UITabBar.appearance().shadowImage = UIImage()
    UITabBar.appearance().clipsToBounds = true
    UITabBarItem.appearance().setTitleTextAttributes(
      [
        .font: UIFont.fancy.text.small
      ],
      for: .normal
    )
  }
  
  func setupNavigationBarAppearance() {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithDefaultBackground()
    appearance.backgroundColor = SKStyleAsset.onyx.color.withAlphaComponent(0.99)
    appearance.shadowColor = .clear
    appearance.shadowImage = UIImage()
    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().compactAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
    if #available(iOS 15.0, *) {
      UINavigationBar.appearance().compactScrollEdgeAppearance = appearance
    }
    UINavigationBar.appearance().isTranslucent = true
    UINavigationBar.appearance().titleTextAttributes = textAttributes
    UINavigationBar.appearance().tintColor = SKStyleAsset.azure.color
    UINavigationBar.appearance().barTintColor = SKStyleAsset.onyx.color.withAlphaComponent(0.99)
  }
  
  func setupBarButtonItemAppearance() {
    UIBarButtonItem.appearance(
      whenContainedInInstancesOf: [UINavigationBar.self]
    ).setTitleTextAttributes(textAttributes, for: [])
    UIBarButtonItem.appearance(
      whenContainedInInstancesOf: [UINavigationBar.self]
    ).setTitleTextAttributes(
      textAttributes,
      for: .normal
    )
    UIBarButtonItem.appearance(
      whenContainedInInstancesOf: [UINavigationBar.self]
    ).setTitleTextAttributes(textAttributes, for: .highlighted)
    UIBarButtonItem.appearance(
      whenContainedInInstancesOf: [UINavigationBar.self]
    ).setTitleTextAttributes(
      textAttributes,
      for: .selected
    )
    UIBarButtonItem.appearance(
      whenContainedInInstancesOf: [UINavigationBar.self]
    ).setTitleTextAttributes(textAttributes, for: .focused)
    UIBarButtonItem.appearance(
      whenContainedInInstancesOf: [UINavigationBar.self]
    ).setTitleTextAttributes(textAttributes, for: .disabled)
    }
}
