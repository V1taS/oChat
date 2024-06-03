//
//  ConfirmSendPaymentScreenView.swift
//  oChat
//
//  Created by Vitalii Sosin on 26.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions

struct ConfirmSendPaymentScreenView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: ConfirmSendPaymentScreenPresenter
  
  // MARK: - Body
  
  var body: some View {
    VStack(spacing: .zero) {
      ScrollView(showsIndicators: false) {
        createContent()
      }
      
      createMainButton()
    }
    .padding(.horizontal, .s4)
    .presentationDragIndicator(.hidden)
  }
}

// MARK: - Private

private extension ConfirmSendPaymentScreenView {
  func createContent() -> some View {
    VStack(spacing: .s6) {
      AsyncNetworkImageView(
        .init(
          imageUrl: presenter.stateTokenModel.imageTokenURL,
          size: .init(width: CGFloat.s20, height: .s20),
          cornerRadiusType: .circle
        )
      )
      
      TitleAndSubtitleView(
        title: .init(text: presenter.getHelperTitle()),
        description: .init(text: presenter.getHelperSubtitle()),
        style: .standart
      )
      
      WidgetCryptoView(presenter.stateWidgetCryptoModels)
        .padding(.top, .s4)
    }
  }
  
  func createMainButton() -> some View {
    MainButtonView(
      text: presenter.getMainButtonTitle(),
      isEnabled: true,
      style: .primary,
      action: {
        presenter.passTokenSendingValidation()
      }
    )
    .padding(.bottom, .s4)
  }
}

// MARK: - Preview

struct ConfirmSendPaymentScreenView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      ConfirmSendPaymentScreenAssembly().createModule(
        .binanceMock,
        recipientAddress: "kwgngkjnwgkfe",
        services: ApplicationServicesStub()
      ).viewController
    }
  }
}
