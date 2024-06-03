//
//  MainScreenView.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI

struct MainScreenView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: MainScreenPresenter
  
  // MARK: - Body
  
  var body: some View {
    VStack(spacing: .zero) {
      ScrollView(.vertical, showsIndicators: false) {
        VStack(spacing: .zero) {
          createTitleAndSubtitleView()
            .padding(.top, .s5)
          
          createButtonPanelView()
            .padding(.top, .s5)
          
          WidgetCryptoView(presenter.stateCryptoCurrencyList)
            .padding(.top, .s7)
        }
        .padding(.horizontal, .s4)
      }
      .refreshable {
        presenter.refreshable()
      }
    }
  }
}

// MARK: - Private

private extension MainScreenView {
  func createTitleAndSubtitleView() -> AnyView {
    AnyView(
      TitleAndSubtitleView(
        title: .init(
          text: presenter.stateTotalWalletAmount,
          lineLimit: 1,
          isSelectable: false,
          isSecure: presenter.stateIsSecure,
          action: {}
        )
      )
    )
  }
  
  func createButtonPanelView() -> AnyView {
    AnyView(
      HStack(spacing: .s4) {
        Spacer()
        CircleButtonView(
          text: presenter.getSendButtonTitle(),
          type: .send,
          size: .standart,
          action: {
            presenter.moduleOutput?.openSendCoinScreen()
          }
        )
        CircleButtonView(
          text: presenter.getReceiveButtonTitle(),
          type: .receive,
          size: .standart,
          action: {
            presenter.moduleOutput?.openReceiveCoinScreen()
          }
        )
        Spacer()
      }
    )
  }
}

// MARK: - Preview

struct MainScreenView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      MainScreenAssembly().createModule().viewController
    }
  }
}
