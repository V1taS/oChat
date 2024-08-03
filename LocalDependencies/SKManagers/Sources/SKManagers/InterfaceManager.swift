//
//  InterfaceManager.swift
//  SKManagers
//
//  Created by Vitalii Sosin on 03.08.2024.
//

import UIKit
import SKAbstractions
import SKStyle
import SKFoundation

public final class InterfaceManager: IInterfaceManager {
  
  // MARK: - Init
  
  public init() {}
  
  // MARK: - Public func
  
  public func setRedDotToTabBar(value: String?) {
    DispatchQueue.main.async {
      guard let tabBarController = UIApplication.currentWindow?.rootViewController as? UITabBarController,
            (tabBarController.tabBar.items?.count ?? .zero) > .zero else {
        return
      }
      
      tabBarController.tabBar.items?[.zero].badgeValue = value
      tabBarController.tabBar.items?[.zero].badgeColor = SKStyleAsset.constantRuby.color
    }
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
