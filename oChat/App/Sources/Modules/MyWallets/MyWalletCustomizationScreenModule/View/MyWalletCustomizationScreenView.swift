//
//  MyWalletCustomizationScreenView.swift
//  oChat
//
//  Created by Vitalii Sosin on 09.05.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions

struct MyWalletCustomizationScreenView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: MyWalletCustomizationScreenPresenter
  
  // MARK: - Body
  
  var body: some View {
    VStack(spacing: .zero) {
      ScrollView(.vertical, showsIndicators: false) {
        WalletCardView(
          .init(
            walletName: presenter.getWalletName(),
            walletAddress: "",
            totalAmount: presenter.getTotalAmount(),
            currency: presenter.stateCurrency,
            walletStyle: .standard
          )
        )
        
        InputView(
          .init(
            text: presenter.stateNewInputText,
            bottomHelper: nil,
            isTextFieldFocused: false,
            isColorFocusBorder: true,
            keyboardType: .default,
            maxLength: 20,
            textFont: nil,
            bottomHelperFont: nil,
            backgroundColor: nil,
            borderColor: nil,
            style: .topHelper(text: presenter.getTopInputHelper()),
            rightButtonType: .clear,
            rightButtonAction: nil,
            onTextFieldFocusedChange: { isFocused, text in
              guard !isFocused else {
                return
              }
              presenter.changeInputText(text: text)
            }
          )
        )
        .padding(.horizontal, .s4)
        .padding(.top, .s4)
      }
      
      MainButtonView(
        text: presenter.getMainButtonTitle(),
        isEnabled: !presenter.stateNewInputText.isEmpty &&
        presenter.stateNewInputText != presenter.stateOldInputText,
        action: {
          presenter.confirmButtonPressed()
        }
      )
      .padding(.horizontal, .s4)
      .padding(.bottom, .s4)
    }
  }
}

// MARK: - Private

private extension MyWalletCustomizationScreenView {}

// MARK: - Preview

struct MyWalletCustomizationScreenView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      MyWalletCustomizationScreenAssembly().createModule(
        .mock,
        services: ApplicationServicesStub()
      ).viewController
    }
  }
}
