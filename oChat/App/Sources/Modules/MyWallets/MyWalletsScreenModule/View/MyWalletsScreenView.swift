//
//  MyWalletsScreenView.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions

struct MyWalletsScreenView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: MyWalletsScreenPresenter
  
  // MARK: - Body
  
  var body: some View {
    VStack(spacing: .zero) {
      ScrollView(showsIndicators: false) {
        createWalletsView()
        createAddWalletButtonView()
      }
    }
    .padding(.horizontal, .s4)
  }
}

// MARK: - Private

private extension MyWalletsScreenView {
  func createWalletsView() -> some View {
    VStack(spacing: .zero) {
      WidgetCryptoView(presenter.stateWidgetCryptoModels)
        .padding(.top, .s4)
    }
  }
  
  func createAddWalletButtonView() -> some View {
    VStack(spacing: .zero) {
      RoundButtonView(
        style: .custom(
          image: Image(systemName: "plus"),
          text: presenter.getRoundButtonTitle(),
          imageColor: SKStyleAsset.ghost.swiftUIColor
        ),
        action: {
          presenter.moduleOutput?.openAddNewWalletSheet()
        }
      )
      .padding(.top, .s4)
    }
  }
}

// MARK: - Preview

struct MyWalletsScreenView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      MyWalletsScreenAssembly().createModule(ApplicationServicesStub()).viewController
    }
  }
}
