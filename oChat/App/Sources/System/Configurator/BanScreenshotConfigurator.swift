//
//  BanScreenshotConfigurator.swift
//  oChat
//
//  Created by Vitalii Sosin on 23.07.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SKAbstractions
import SKUIKit
import UIKit
import SKStyle
import SwiftUI

struct BanScreenshotConfigurator: Configurator {
  
  // MARK: - Private properties
  
  private let window: UIWindow?
  
  // MARK: - Init
  
  init(window: UIWindow?) {
    self.window = window
  }
  
  // MARK: - Internal func
  
  func configure() {
    guard let window else { return }
    makeBanScreenshot(window: window)
  }
}

// MARK: - Private

private extension BanScreenshotConfigurator {
  func makeBanScreenshot(window: UIWindow) {
    Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
      let field = UITextField()
      let view = UIView(frame: CGRect(x: 0, y: 0, width: field.frame.width, height: field.frame.height))
      let banScreenshotView = UIHostingController(
        rootView: BrandingStubView(text: OChatStrings.CommonStrings.BanScreenshotView.description)
      )
      banScreenshotView.view.frame = CGRect(
        x: 0,
        y: 0,
        width: UIScreen.main.bounds.width,
        height: UIScreen.main.bounds.height
      )
      
      field.isSecureTextEntry = true
      window.addSubview(field)
      view.addSubview(banScreenshotView.view)
      
      window.layer.superlayer?.addSublayer(field.layer)
      field.layer.sublayers?.last!.addSublayer(window.layer)
      
      field.leftView = view
      field.leftViewMode = .always
    }
  }
}
