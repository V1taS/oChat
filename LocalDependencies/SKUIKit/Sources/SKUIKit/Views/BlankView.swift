//
//  SwiftUIView.swift
//  SKUIKit
//
//  Created by Vladimir Stepanchikov on 7/22/24.
//

import SwiftUI
import SKStyle
import SKFoundation

public struct BlankView: View {
  private let text: String

  public init(text: String) {
    self.text = text
  }

  public var body: some View {
    ZStack {
      SKStyleAsset.onyx.swiftUIColor
      VStack {
        Text(text)
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
  BlankView(text: "Taking a screenshot is not available")
}
#endif
