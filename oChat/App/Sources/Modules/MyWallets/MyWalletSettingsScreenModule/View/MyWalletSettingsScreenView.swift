//
//  MyWalletSettingsScreenView.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions

struct MyWalletSettingsScreenView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: MyWalletSettingsScreenPresenter
  
  // MARK: - Body
  
  var body: some View {
    VStack(spacing: .zero) {
      ScrollView(.vertical, showsIndicators: false) {
        VStack(spacing: .s6) {
          WalletCardView(
            .init(
              walletName: presenter.getWalletName(),
              walletAddress: "",
              totalAmount: presenter.getTotalAmount(),
              currency: presenter.stateCurrency,
              walletStyle: .standard
            )
          )
          
          WidgetCryptoView(presenter.statePrimaryWidgetCryptoModels)
          WidgetCryptoView(presenter.stateSecondaryWidgetCryptoModels)
          WidgetCryptoView(presenter.stateTertiaryWidgetCryptoModels)
        }
        .padding(.horizontal, .s4)
        .padding(.top, .s3)
      }
    }
  }
}

// MARK: - Private

private extension MyWalletSettingsScreenView {}

// MARK: - Preview

struct MyWalletSettingsScreenView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      MyWalletSettingsScreenAssembly().createModule(
        services: ApplicationServicesStub(),
        walletModel: .mock
      ).viewController
    }
  }
}
