//
//  QRReceivePaymentScreenView.swift
//  oChat
//
//  Created by Vitalii Sosin on 03.05.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions

struct QRReceivePaymentScreenView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: QRReceivePaymentScreenPresenter
  
  // MARK: - Body
  
  var body: some View {
    VStack(spacing: .zero) {
      ScrollView(showsIndicators: false) {
        VStack(spacing: .s2) {
          TitleAndSubtitleView(
            description: .init(
              text: presenter.getDescriptionTitle()
            ),
            alignment: .center,
            style: .standart
          )
          
          QRCodeView(
            qrCodeImage: presenter.stateQrImage,
            dataString: presenter.stateReplenishmentAddress
          )
          .frame(
            width: UIScreen.main.bounds.width / 1.5,
            height: UIScreen.main.bounds.width / 1.1
          )
          
          HStack {
            RoundButtonView(
              style: .copy(text: presenter.getCopyButtonTitle()),
              action: {
                presenter.copyButtonAction()
              }
            )
            
            RoundButtonView(
              style: .custom(image: Image(systemName: "square.and.arrow.up"), text: nil),
              action: {
                presenter.shareQRReceivePaymentScreenTapped()
              }
            )
          }
        }
      }
      
      Spacer()
      
      MainButtonView(
        text: presenter.getMainButtonTitle(),
        isEnabled: true,
        style: .primary,
        action: {
          presenter.moduleOutput?.closeQRReceivePaymentScreenTapped()
        }
      )
    }
    .padding(.horizontal, .s4)
    .padding(.bottom, .s4)
  }
}

// MARK: - Private

private extension QRReceivePaymentScreenView {}

// MARK: - Preview

struct QRReceivePaymentScreenView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      QRReceivePaymentScreenAssembly().createModule(
        services: ApplicationServicesStub(),
        tokenModel: .cardanoMock
      ).viewController
    }
  }
}
