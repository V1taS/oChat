//
//  SendPaymentScreenView.swift
//  oChat
//
//  Created by Vitalii Sosin on 23.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKFoundation
import SKAbstractions

struct SendPaymentScreenView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: SendPaymentScreenPresenter
  
  // MARK: - Body
  
  var body: some View {
    VStack(spacing: .zero) {
      ScrollView(showsIndicators: false) {
        createContent()
          .padding(.top, .s4)
      }
      
      createMainButton()
    }
    .padding(.horizontal, .s4)
  }
}

// MARK: - Private

private extension SendPaymentScreenView {
  func createContent() -> some View {
    VStack(spacing: .s6) {
      CryptoConverterView(
        .init(
          text: $presenter.stateAmountToken,
          fieldType: .cryptocurrency,
          placeholder: presenter.getSendCryptoPlaceholderTitle(),
          leftSide: .init(
            title: presenter.getSendCryptoHeaderTitle(),
            shortFormCryptoName: presenter.stateScreenModel.tokenModel.ticker,
            longFormCryptoName: presenter.stateScreenModel.tokenModel.name,
            imageCrypto: presenter.stateScreenModel.tokenModel.imageTokenURL,
            isSelectable: presenter.stateScreenModel.screenType == .openFromMainScreen,
            action: {
              presenter.moduleOutput?.openListTokensScreen(presenter.stateScreenModel.tokenModel)
            }
          ),
          rightSide: .init(
            totalAmount: .init(
              totalCryptoTitle: presenter.getTotalCryptoTitle(),
              totalCrypto: presenter.getTotalCryptoMaxTitle(),
              applyMaximumAmount: {
                presenter.applyMaximumAmount()
              }
            ),
            fieldWithAmount: .init(
              currency: presenter.calculateCurrencyAndCrypto().primaryName
            ),
            currencySwitcher: .init(
              amountInCurrency: presenter.calculateCurrencyAndCrypto().secondaryAmount,
              switchCurrencyAction: {
                presenter.switchCurrencyAction()
              }
            )
          ),
          onTextChange: { newValue in
            presenter.onAmountChange(newValue)
          }
        )
      )
      
      CryptoConverterView(.init(
        text: $presenter.stateAddressRecipient, 
        fieldType: .standart,
        placeholder: presenter.getWhomCryptoPlaceholderTitle(),
        leftSide: .init(title: presenter.getWhomCryptoHeaderTitle()),
        rightSide: nil,
        onTextChange: { newValue in
          presenter.onAddressChange(newValue)
        }
      ))
    }
  }
  
  func createMainButton() -> some View {
    MainButtonView(
      text: presenter.getMainButtonTitle(),
      isEnabled: presenter.stateIsValidMainButton,
      style: .primary,
      action: {
        presenter.moduleOutput?.openConfirmAndSendScreen(
          presenter.stateScreenModel.tokenModel,
          recipientAddress: presenter.stateAddressRecipient
        )
      }
    )
    .padding(.bottom, .s4)
  }
}

// MARK: - Preview

struct SendPaymentScreenView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      SendPaymentScreenAssembly().createModule(
        .init(
          screenType: .openFromMainScreen,
          tokenModel: .binanceMock
        ),
        ApplicationServicesStub()
      ).viewController
    }
  }
}
