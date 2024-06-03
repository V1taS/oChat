//
//  ImportWalletScreenView.swift
//  oChat
//
//  Created by Vitalii Sosin on 20.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions

struct ImportWalletScreenView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: ImportWalletScreenPresenter
  
  // MARK: - Body
  
  var body: some View {
    createInitialView()
  }
}

// MARK: - Private

private extension ImportWalletScreenView {
  func createInitialView() -> some View {
    return VStack(spacing: .zero) {
      ScrollView(showsIndicators: false) {
        createTitleView()
        createInputTextView()
          .frame(minHeight: 300)
          .padding(.top, .s4)
      }
      
      Spacer()
      createMainButtonView()
    }
    .padding(.horizontal, .s4)
  }
  
  func createTitleView() -> some View {
    TitleAndSubtitleView(
      title: .init(
        text: presenter.getScreenDescription()
      ),
      style: .small
    )
    .padding(.top, .s5)
  }
  
  func createInputTextView() -> some View {
    return createInputText()
  }
  
  func createMainButtonView() -> some View {
    MainButtonView(
      text: presenter.getButtonTitle(),
      isEnabled: presenter.stateIsValidation,
      style: presenter.stateIsValidation ? .primary : .secondary,
      action: {
        presenter.checkingTheImportedWallet()
      }
    )
    .padding(.bottom, .s4)
  }
  
  func createInputText() -> some View {
    return InputView(.init(
      text: presenter.statePhraseInputText,
      placeholder: presenter.getScreenDescription(),
      bottomHelper: presenter.stateValidationhelperText,
      isError: !presenter.stateIsValidation && !presenter.statePhraseInputText.isEmpty,
      isEnabled: true,
      isTextFieldFocused: false,
      isColorFocusBorder: true,
      keyboardType: .default,
      maxLength: 100,
      borderColor: SKStyleAsset.slate.swiftUIColor,
      style: .none,
      rightButtonType: .clear,
      rightButtonAction: {},
      onTextFieldFocusedChange: { isFocused, text in
        guard !isFocused else {
          return
        }
        presenter.onTextFieldChange(text)
      }
    ))
  }
}

// MARK: - Preview

struct ImportWalletScreenView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      ImportWalletScreenAssembly().createModule(
        walletType: .seedPhrase,
        services: ApplicationServicesStub()
      ).viewController
    }
  }
}
