//
//  SceneDelegate+makeBanScreenshot.swift
//  oChat
//
//  Created by Vladimir Stepanchikov on 7/20/24.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SwiftUI
import SKFoundation
import SKStyle

extension SceneDelegate {
  func makeBanScreenshot(window: UIWindow) {
    Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
      let field = UITextField()
      let view = UIView(frame: CGRect(x: 0, y: 0, width: field.frame.width, height: field.frame.height))
      let banScreenshotView = UIHostingController(rootView: BanScreenshotView())
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

private struct BanScreenshotView: View {
  var body: some View {
    ZStack {
      SKStyleAsset.onyx.swiftUIColor
      VStack {
        Text(OChatStrings.CommonStrings.BanScreenshotView.description)
          .font(.fancy.text.largeTitle)
          .foregroundStyle(SKStyleAsset.ghost.swiftUIColor)
          .multilineTextAlignment(.center)
        Image(SKStyleAsset.oChatLogo.name, bundle: SKStyleResources.bundle)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: .gridSteps(35))
      }
    }
    .ignoresSafeArea()
  }
}

#if DEBUG
#Preview {
  BanScreenshotView()
}
#endif
