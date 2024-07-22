//
//  SceneDelegate+makeBanScreenshot.swift
//  oChat
//
//  Created by Vladimir Stepanchikov on 7/20/24.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SwiftUI
import SKUIKit

extension SceneDelegate {
  func makeBanScreenshot(window: UIWindow) {
    Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
      let field = UITextField()
      let view = UIView(frame: CGRect(x: 0, y: 0, width: field.frame.width, height: field.frame.height))
      let banScreenshotView = UIHostingController(
        rootView: BlankView(text: OChatStrings.CommonStrings.BanScreenshotView.description)
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
