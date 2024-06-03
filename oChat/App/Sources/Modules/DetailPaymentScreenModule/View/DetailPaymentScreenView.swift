//
//  DetailPaymentScreenView.swift
//  oChat
//
//  Created by Vitalii Sosin on 05.05.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKFoundation

struct DetailPaymentScreenView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: DetailPaymentScreenPresenter
  
  // MARK: - Body
  
  var body: some View {
    VStack(spacing: .zero) {
      ScrollView(showsIndicators: false) {
        createHeaderView()
        createButtonPanelView()
        ChartSectionView(ChartSectionView.mockModel())
        createActivityView()
      }
    }
  }
}

// MARK: - Private

private extension DetailPaymentScreenView {
  func createHeaderView() -> some View {
    HStack {
      TitleAndSubtitleView(
        title: .init(
          text: presenter.stateTokenModel.tokenAmount.format(
            currency: presenter.stateTokenModel.ticker,
            formatType: .superPrecise
          )
        ),
        description: .init(
          text: presenter.stateTokenModel.costInCurrency.format(
            currency: presenter.stateTokenModel.currency?.type.details.symbol,
            formatType: .precise
          )
        ),
        alignment: .leading,
        style: .standart
      )
      
      Spacer()
      
      AsyncNetworkImageView(
        .init(
          imageUrl: presenter.stateTokenModel.imageTokenURL,
          size: .init(width: CGFloat.s15, height: .s15),
          cornerRadiusType: .circle
        )
      )
    }
    .padding(.horizontal, .s4)
    .padding(.top, .s4)
  }
  
  func createButtonPanelView() -> some View {
    VStack(spacing: .zero) {
      Divider()
        .padding(.bottom, .s5)
      
      HStack(spacing: .s4) {
        Spacer()
        CircleButtonView(
          text: presenter.getButtonSendTitle(),
          type: .send,
          size: .standart,
          action: {
            presenter.moduleOutput?.openSendPaymentScreen(presenter.stateTokenModel)
          }
        )
        
        CircleButtonView(
          text: presenter.getButtonReceiveTitle(),
          type: .receive,
          size: .standart,
          action: {
            presenter.moduleOutput?.openReceivePaymentScreen(presenter.stateTokenModel)
          }
        )
        Spacer()
      }
      Divider()
        .padding(.top, .s5)
    }
    .padding(.top, .s5)
  }
  
  func createActivityView() -> some View {
    VStack(spacing: .zero) {
      ForEach(presenter.stateListActivity, id: \.date) { model in
        HStack {
          TitleAndSubtitleView(
            title: .init(text: model.date),
            alignment: .leading,
            style: .standart
          )
          .padding(.top, .s4)
          Spacer()
        }
        
        ForEach(model.listActivity, id: \.id) { widgetsModel in
          WidgetCryptoView(widgetsModel)
            .padding(.top, .s3)
        }
      }
    }
    .padding(.horizontal, .s4)
    .padding(.top, .s4)
  }
}

// MARK: - Preview

struct DetailPaymentScreenView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      DetailPaymentScreenAssembly().createModule(
        tokenModel: .binanceMock
      ).viewController
    }
  }
}
