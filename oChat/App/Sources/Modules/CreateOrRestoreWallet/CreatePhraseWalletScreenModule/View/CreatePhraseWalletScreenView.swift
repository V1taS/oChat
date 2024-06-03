//
//  CreatePhraseWalletScreenView.swift
//  oChat
//
//  Created by Vitalii Sosin on 18.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import Lottie
import SKAbstractions

struct CreatePhraseWalletScreenView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: CreatePhraseWalletScreenPresenter
  
  // MARK: - Body
  
  var body: some View {
    createContentView()
  }
}

// MARK: - Private

private extension CreatePhraseWalletScreenView {
  func createContentView() -> some View {
    Group {
      switch presenter.stateCurrentStateScreen {
      case .generatingWallet:
        createGeneratingWalletView()
      case .walletCreated:
        createWalletCreatedView()
      }
    }
  }
  
  func createGeneratingWalletView() -> some View {
    return createLoaderAndTitleView(
      animationName: presenter.stateGeneratingWalletAnimationName,
      title: presenter.stateGeneratingWalletTitle
    )
  }
  
  func createWalletCreatedView() -> some View {
    return createLoaderAndTitleView(
      animationName: presenter.stateWalletCreatedAnimationName,
      title: presenter.stateWalletCreatedTitle
    )
  }
  
  func createLoaderAndTitleView(
    animationName: String,
    title: String,
    description: String = "") -> some View {
      VStack(spacing: .s5) {
        Spacer()
        LottieView(animation: .named(animationName))
          .resizable()
          .looping()
          .aspectRatio(contentMode: .fit)
          .frame(width: 200, height: 200)
        
        TitleAndSubtitleView(
          title: .init(text: title),
          description: .init(text: description),
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

struct CreatePhraseWalletScreenView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      CreatePhraseWalletScreenAssembly().createModule(
        .seedPhrase12,
        ApplicationServicesStub()
      ).viewController
    }
  }
}
