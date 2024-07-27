//
//  SuggestScreenView.swift
//  oChat
//
//  Created by Vitalii Sosin on 19.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import Lottie
import SKAbstractions

struct SuggestScreenView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: SuggestScreenPresenter
  
  // MARK: - Body
  
  var body: some View {
    VStack(spacing: .zero) {
      createLoaderAndTitleView()
      
      MainButtonView(
        text: presenter.getSuggestModel().buttonTitle,
        action: {
          Task {
            await presenter.suggestScreenConfirmButtonTapped()
          }
        }
      )
      .padding(.bottom, .s4)
      .padding(.horizontal, .s4)
    }
  }
}

// MARK: - Private

private extension SuggestScreenView {
  func createLoaderAndTitleView() -> some View {
    VStack(spacing: .s5) {
      Spacer()
      LottieView(animation: .named(presenter.getSuggestModel().animationName))
        .resizable()
        .looping()
        .aspectRatio(contentMode: .fit)
        .frame(width: 200, height: 200)
      
      TitleAndSubtitleView(
        title: .init(text: presenter.getSuggestModel().title),
        description: .init(text: presenter.getSuggestModel().description),
        style: .standart
      )
      .padding(.horizontal, .s4)
      
      Spacer()
      Spacer()
      HStack { Spacer() }
    }
  }
}

// MARK: - Preview

struct SuggestScreenView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      SuggestScreenAssembly().createModule(
        .setNotifications,
        services: ApplicationServicesStub()
      ).viewController
    }
  }
}
