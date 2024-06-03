//
//  ReceivePaymentScreenView.swift
//  oChat
//
//  Created by Vitalii Sosin on 03.05.2024.
//

import SKStyle
import SKUIKit
import SwiftUI

struct ReceivePaymentScreenView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: ReceivePaymentScreenPresenter
  
  // MARK: - Body
  
  var body: some View {
    VStack(spacing: .zero) {
      ScrollView(showsIndicators: false) {
        ForEach(presenter.stateWidgetModels, id: \.id) { model in
          VStack(spacing: .s1) {
            HStack {
              Text(model.title)
                .font(.fancy.text.regular)
                .foregroundColor(SKStyleAsset.slate.swiftUIColor)
                .allowsHitTesting(false)
              
              Spacer()
            }
            
            WidgetCryptoView(model.widget)
          }
          .padding(.top, .s5)
        }
      }
      
      Spacer()
      
      MainButtonView(
        text: presenter.getButtonTitle(),
        isEnabled: true,
        style: .primary,
        action: {
          presenter.moduleOutput?.continueButtonReceivePaymentPressed(presenter.stateTokenModel)
        }
      )
    }
    .padding(.horizontal, .s4)
    .padding(.bottom, .s4)
  }
}

// MARK: - Private

private extension ReceivePaymentScreenView {}

// MARK: - Preview

struct ReceivePaymentScreenView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      ReceivePaymentScreenAssembly().createModule().viewController
    }
  }
}
