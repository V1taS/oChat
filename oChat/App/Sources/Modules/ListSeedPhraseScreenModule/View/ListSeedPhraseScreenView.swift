//
//  ListSeedPhraseScreenView.swift
//  oChat
//
//  Created by Vitalii Sosin on 18.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions

/// Псевдоним для двух массивов с фразами
private typealias RecoveryPhraseList = (firstHalf: [String], secondHalf: [String])

struct ListSeedPhraseScreenView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: ListSeedPhraseScreenPresenter
  
  // MARK: - Body
  
  var body: some View {
    VStack(spacing: .zero) {
      ScrollView(.vertical, showsIndicators: false) {
        createTitleAndSubtitleView()
        
        createRecoveryPhraseView(
          list: createRecoveryPhrase(list: presenter.stateListSeedPhrase)
        )
        .padding(.top, .s6)
        
        createCopyButtonView()
      }
      
      Spacer()
      
      if presenter.stateScreenType == .termsAndConditionsScreen {
        VStack(spacing: .s6) {
          CheckmarkView(
            text: presenter.stateTermsOfAgreementTitle,
            action: { newValue in
              presenter.stateIsConfirmationRequirements = newValue
            }
          )
          
          MainButtonView(
            text: presenter.stateContinueButtonTitle,
            isEnabled: presenter.stateIsConfirmationRequirements,
            style: presenter.stateIsConfirmationRequirements ? .primary : .secondary,
            action: {
              presenter.saveListSeedAndContinueButtonTapped()
            }
          )
        }
        .padding(.horizontal, .s4)
        .padding(.bottom, .s4)
      }
    }
  }
}

// MARK: - Private

private extension ListSeedPhraseScreenView {
  func createCopyButtonView() -> some View {
    RoundButtonView(
      style: .copy(text: presenter.stateCopyButtonTitle),
      action: {
        presenter.copyListSeedButtonTapped()
      }
    )
  }
  
  func createTitleAndSubtitleView() -> some View {
    TitleAndSubtitleView(
      description: .init(
        text: presenter.stateHeaderDescription
      ),
      style: .standart
    )
    .padding(.horizontal, .s4)
  }
  
  func createRecoveryPhraseView(list: RecoveryPhraseList) -> some View {
    HStack(alignment: .center, spacing: .zero) {
      Spacer()
      
      VStack(alignment: .leading, spacing: .zero) {
        ForEach(Array(list.firstHalf.enumerated()), id: \.offset) { index, item in
          createPhraseView(number: "\(index + 1)", phrase: item)
        }
      }
      
      Spacer()
      Spacer()
      
      VStack(alignment: .leading, spacing: .zero) {
        ForEach(Array(list.secondHalf.enumerated()), id: \.offset) { index, item in
          createPhraseView(
            number: "\(list.secondHalf.count + index + 1)",
            phrase: item
          )
        }
      }
      Spacer()
      Spacer()
    }
  }
  
  func createPhraseView(number: String, phrase: String) -> some View {
    HStack(alignment: .center, spacing: .zero) {
      Text("\(number).")
        .font(.fancy.text.regularMedium)
        .foregroundColor(SKStyleAsset.slate.swiftUIColor)
        .allowsHitTesting(false)
        .frame(width: .s10)
      
      Text("\(phrase)")
        .font(.fancy.text.regular)
        .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
        .allowsHitTesting(false)
    }
    .padding(.bottom, .s2)
  }
  
  func createRecoveryPhrase(list: [String]) -> RecoveryPhraseList {
    let middleIndex = list.count / 2
    let firstHalf = Array(list[..<middleIndex])
    let secondHalf = Array(list[middleIndex...])
    return (firstHalf: firstHalf, secondHalf: secondHalf)
  }
}

// MARK: - Preview

struct ListSeedPhraseScreenView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      ListSeedPhraseScreenAssembly().createModule(
        services: ApplicationServicesStub(),
        screenType: .termsAndConditionsScreen, 
        walletModel: .mock
      ).viewController
    }
  }
}
