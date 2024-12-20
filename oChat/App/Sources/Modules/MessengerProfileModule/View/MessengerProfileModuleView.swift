//
//  MessengerProfileModuleView.swift
//  MessengerSDK
//
//  Created by Vitalii Sosin on 06.06.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions

struct MessengerProfileModuleView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: MessengerProfileModulePresenter
  
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
            dataString: presenter.stateMyOnionAddress
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
    }
    .padding(.horizontal, .s4)
    .padding(.bottom, .s4)
  }
}

// MARK: - Private

private extension MessengerProfileModuleView {}

// MARK: - Preview

struct MessengerProfileModuleView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      MessengerProfileModuleAssembly().createModule(
        services: ApplicationServicesStub()
      ).viewController
    }
  }
}
