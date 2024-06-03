//
//  TransactionInformationSheetView.swift
//  oChat
//
//  Created by Vitalii Sosin on 07.05.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions

struct TransactionInformationSheetView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: TransactionInformationSheetPresenter
  
  // MARK: - Body
  
  var body: some View {
    CustomSheetView {
      VStack(spacing: .zero) {
        createHeaderView()
        createWidgetListView()
        createTransactionView()
      }
      .padding(.top, .s4)
    }
  }
}

// MARK: - Private

private extension TransactionInformationSheetView {
  func createHeaderView() -> some View {
    VStack(spacing: .zero) {
      AsyncNetworkImageView(
        .init(
          imageUrl: presenter.stateTransactionModel.imageTokenURL,
          size: .init(width: CGFloat.s15, height: .s15),
          cornerRadiusType: .circle
        )
      )
      
      TitleAndSubtitleView(
        title: .init(text: presenter.getTokenAmountTitle()),
        description: .init(text: presenter.getCurrencyAmountTitle()),
        style: .standart
      )
      .padding(.top, .s6)
      
      TitleAndSubtitleView(
        description: .init(text: presenter.getDateTitle()),
        style: .standart
      )
    }
  }
  
  func createWidgetListView() -> some View {
    WidgetCryptoView(presenter.stateWidgetCryptoModels)
      .padding(.top, .s6)
  }
  
  func createTransactionView() -> some View {
    RoundButtonView(
      style: .custom(
        image: Image(systemName: "network"),
        text: presenter.getTransactionButtonTitle(),
        imageColor: SKStyleAsset.ghost.swiftUIColor
      ),
      action: {
        presenter.transactionButtonTapped()
      }
    )
    .padding(.top, .s4)
  }
}

// MARK: - Preview

struct TransactionInformationSheetView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      TransactionInformationSheetAssembly().createModule(
        model: .singleMock,
        services: ApplicationServicesStub()
      ).viewController
    }
  }
}
