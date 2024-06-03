//
//  HintBackupScreenView.swift
//  oChat
//
//  Created by Vitalii Sosin on 18.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import Lottie

struct HintBackupScreenView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: HintBackupScreenPresenter
  
  // MARK: - Body
  
  var body: some View {
    VStack(spacing: .zero) {
      ScrollView(.vertical, showsIndicators: false) {
        VStack(spacing: .zero) {
          createHeaderView()
          createInformationBloksView()
            .padding(.top, .s12)
        }
        .padding(.top, .s2)
      }
      
      Spacer()
      MainButtonView(
        text: presenter.getHintModel().buttonTitle,
        action: {
          presenter.moduleOutput?.continueHintBackupButtonTapped()
        }
      )
      .padding(.horizontal, .s4)
      .padding(.bottom, .s4)
    }
  }
}

// MARK: - Private

private extension HintBackupScreenView {
  func createHeaderView() -> some View {
    let model = presenter.getHintModel()
    return VStack(spacing: .zero) {
      if let lottieAnimationName = model.lottieAnimationName {
        LottieView(animation: .named(lottieAnimationName))
          .resizable()
          .looping()
          .aspectRatio(contentMode: .fit)
          .frame(width: 150, height: 150)
          .offset(y: -20)
      }
      
      TitleAndSubtitleView(
        title: .init(text: model.headerTitle),
        description: .init(text: model.headerDescription),
        style: .standart
      )
      .padding(.horizontal, .s4)
    }
  }
  
  func createInformationBloksView() -> some View {
    let model = presenter.getHintModel()
    return VStack(spacing: .s4) {
      createInformationBlokView(
        title: model.oneTitle,
        description: model.oneDescription,
        systemImageName: model.oneSystemImageName
      )
      
      createInformationBlokView(
        title: model.twoTitle,
        description: model.twoDescription,
        systemImageName: model.twoSystemImageName
      )
      
      createInformationBlokView(
        title: model.threeTitle,
        description: model.threeDescription,
        systemImageName: model.threeSystemImageName
      )
    }
  }
  
  func createInformationBlokView(
    title: String,
    description: String,
    systemImageName: String
  ) -> some View {
    HStack(alignment: .center, spacing: .zero) {
      Image(systemName: systemImageName)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .foregroundColor(SKStyleAsset.azure.swiftUIColor)
        .frame(width: 30, height: 30)
        .allowsHitTesting(false)
      
      VStack(alignment: .leading, spacing: .s1) {
        Text(title)
          .font(.fancy.text.regularMedium)
          .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
          .multilineTextAlignment(.leading)
          .allowsHitTesting(false)
          .padding(.horizontal, .s4)
        
        Text(description)
          .font(.fancy.text.small)
          .foregroundColor(SKStyleAsset.slate.swiftUIColor)
          .multilineTextAlignment(.leading)
          .allowsHitTesting(false)
          .padding(.horizontal, .s4)
      }
      Spacer()
    }
    .padding(.horizontal, .s4)
  }
}

// MARK: - Preview

struct HintBackupScreenView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      HintBackupScreenAssembly().createModule(.backupPhrase).viewController
    }
  }
}
