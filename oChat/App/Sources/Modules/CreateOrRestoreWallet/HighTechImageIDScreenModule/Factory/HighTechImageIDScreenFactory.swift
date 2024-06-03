//
//  HighTechImageIDScreenFactory.swift
//  oChat
//
//  Created by Vitalii Sosin on 19.04.2024.
//

import SwiftUI
import SKUIKit
import SKStyle

/// Cобытия которые отправляем из Factory в Presenter
protocol HighTechImageIDScreenFactoryOutput: AnyObject {
  /// Открыть шторку с информацией о ImageID
  func openInfoImageIDSheet()
  /// Первое текстовое поле было изменено
  func changeFirstInputText(text: String)
  /// Второе текстовое поле было изменено
  func changeSecondInputText(text: String)
}

/// Cобытия которые отправляем от Presenter к Factory
protocol HighTechImageIDScreenFactoryInput {
  /// Создать заголовок
  func createHeaderTitle(
    _ currentStateScreen: HighTechImageIDScreenState
  ) -> String
  /// Создать модельку по включению дополнительной защиты для изображения
  func createAdditionProtectionModel(
    _ state: HighTechImageIDScreenState,
    firstInputText: String,
    secondInputText: String
  ) -> WidgetCryptoView.Model
  /// Создать заголовок у кнопки
  func createButtonTitle(
    _ currentStateScreen: HighTechImageIDScreenState
  ) -> String
  /// Валидация основной кнопки
  func isValidationMainButton(
    _ currentStateScreen: HighTechImageIDScreenState,
    firstInputText: String,
    secondInputText: String,
    isSaveImageID: Bool,
    isConfirmationRequirements: Bool
  ) -> Bool
  /// Условия пользованием
  func createTermsOfAgreementTitle() -> String
  /// Создать описание текущего шага
  func createStepDescription(
    _ currentStateScreen: HighTechImageIDScreenState
  ) -> String
  /// Создать описание заголовка
  func createHeaderDescription(
    _ currentStateScreen: HighTechImageIDScreenState
  ) -> String
  /// Установить новое состояние экрана
  func setNewStateScreen(
    from currentState: HighTechImageIDScreenState,
    to newState: HighTechImageIDScreenState.StateScreen
  ) -> HighTechImageIDScreenState
  ///  Отключить нажатие на картинку
  func setIsDisabledPhotosPicker(_ currentStateScreen: HighTechImageIDScreenState) -> Bool
}

/// Фабрика
final class HighTechImageIDScreenFactory {
  
  // MARK: - Internal properties
  
  weak var output: HighTechImageIDScreenFactoryOutput?
}

// MARK: - HighTechImageIDScreenFactoryInput

extension HighTechImageIDScreenFactory: HighTechImageIDScreenFactoryInput {
  func setIsDisabledPhotosPicker(_ currentStateScreen: HighTechImageIDScreenState) -> Bool {
    switch currentStateScreen {
    case let .generateImageID(result), let .loginImageID(result):
      switch result {
      case .initialState:
        return false
      default:
        return true
      }
    }
  }
  
  func createHeaderTitle(
    _ currentStateScreen: HighTechImageIDScreenState
  ) -> String {
    switch currentStateScreen {
    case .generateImageID:
      return OChatStrings.HighTechImageIDScreenLocalization
        .State.GenerateImageID.Header.title
    case .loginImageID:
      return OChatStrings.HighTechImageIDScreenLocalization
        .State.LoginImageID.Header.title
    }
  }
  
  func createAdditionProtectionModel(
    _ state: HighTechImageIDScreenState,
    firstInputText: String,
    secondInputText: String
  ) -> WidgetCryptoView.Model {
    createWidgetWithPassword(
      title: OChatStrings.HighTechImageIDScreenLocalization
        .State.AdditionProtection.title,
      state: state,
      firstInputText: firstInputText,
      secondInputText: secondInputText
    )
  }
  
  func createButtonTitle(
    _ currentStateScreen: HighTechImageIDScreenState
  ) -> String {
    switch currentStateScreen {
    case let .generateImageID(result):
      switch result {
      case .finish:
        return OChatStrings.HighTechImageIDScreenLocalization
          .State.Button.Main.GenerateImageIDFinish.title
      default:
        return OChatStrings.HighTechImageIDScreenLocalization
          .State.Button.Main.GenerateImageIDDefault.title
      }
    case let .loginImageID(result):
      switch result {
      case .finish:
        return OChatStrings.HighTechImageIDScreenLocalization
          .State.Button.Main.LoginImageIDFinish.title
      default:
        return OChatStrings.HighTechImageIDScreenLocalization
          .State.Button.Main.LoginImageIDDefault.title
      }
    }
  }
  
  func isValidationMainButton(
    _ currentStateScreen: HighTechImageIDScreenState,
    firstInputText: String,
    secondInputText: String,
    isSaveImageID: Bool,
    isConfirmationRequirements: Bool
  ) -> Bool {
    switch currentStateScreen {
    case let .generateImageID(result):
      switch result {
      case .passCodeImage:
        let passValidation = passValidation(password: firstInputText, confirm: secondInputText)
        return passValidation.isValidation
      case .finish:
        return isSaveImageID && isConfirmationRequirements
      default:
        return true
      }
    case let .loginImageID(result):
      switch result {
      case .initialState:
        return true
      case .passCodeImage:
        return !firstInputText.isEmpty
      case .startUploadImage:
        return true
      case .finish:
        return true
      }
    }
  }
  
  func createTermsOfAgreementTitle() -> String {
    OChatStrings.HighTechImageIDScreenLocalization
      .State.TermsOfAgreement.title
  }
  
  func createStepDescription(
    _ currentStateScreen: HighTechImageIDScreenState
  ) -> String {
    switch currentStateScreen {
    case let .generateImageID(result):
      switch result {
      case .initialState:
        return OChatStrings.HighTechImageIDScreenLocalization
          .Step.GenerateImageID.InitialState.description("1")
      case .passCodeImage:
        return OChatStrings.HighTechImageIDScreenLocalization
          .Step.GenerateImageID.PassCodeImage.description("2")
      case .startUploadImage:
        return OChatStrings.HighTechImageIDScreenLocalization
          .Step.GenerateImageID.StartUploadImage.description("3")
      case .finish:
        return OChatStrings.HighTechImageIDScreenLocalization
          .Step.GenerateImageID.Finish.description("4")
      }
    case let .loginImageID(result):
      switch result {
      case .initialState:
        return OChatStrings.HighTechImageIDScreenLocalization
          .Step.LoginImageID.InitialState.description("1")
      case .passCodeImage:
        return OChatStrings.HighTechImageIDScreenLocalization
          .Step.LoginImageID.PassCodeImage.description("2")
      case .startUploadImage:
        return OChatStrings.HighTechImageIDScreenLocalization
          .Step.LoginImageID.StartUploadImage.description("3")
      case .finish:
        return OChatStrings.HighTechImageIDScreenLocalization
          .Step.LoginImageID.Finish.description("4")
      }
    }
  }
  
  func createHeaderDescription(
    _ currentStateScreen: HighTechImageIDScreenState
  ) -> String {
    switch currentStateScreen {
    case .generateImageID:
      return OChatStrings.HighTechImageIDScreenLocalization
        .State.GenerateImageID.Header.description
    case .loginImageID:
      return OChatStrings.HighTechImageIDScreenLocalization
        .State.LoginImageID.Header.description
    }
  }
  
  func setNewStateScreen(
    from currentState: HighTechImageIDScreenState,
    to newState: HighTechImageIDScreenState.StateScreen
  ) -> HighTechImageIDScreenState {
    switch currentState {
    case .generateImageID:
      return .generateImageID(newState)
    case .loginImageID:
      return .loginImageID(newState)
    }
  }
}

// MARK: - Private

private extension HighTechImageIDScreenFactory {
  func createWidgetWithPassword(
    title: String,
    state: HighTechImageIDScreenState,
    firstInputText: String,
    secondInputText: String
  ) -> WidgetCryptoView.Model {
    var leftSide: WidgetCryptoView.ContentModel?
    if case .generateImageID = state {
      leftSide = .init(
        itemModel: .infoButton(action: { [weak self] in
          self?.output?.openInfoImageIDSheet()
        }),
        titleModel: .init(
          text: title,
          textStyle: .standart
        )
      )
    }
    
    return .init(
      leftSide: leftSide,
      rightSide: nil,
      additionCenterContent: createAdditionProtectionInputViews(
        state: state,
        firstInputText: firstInputText,
        secondInputText: secondInputText
      ),
      isSelectable: false,
      backgroundColor: nil,
      action: {
      }
    )
  }
  
  func createAdditionProtectionInputViews(
    state: HighTechImageIDScreenState,
    firstInputText: String,
    secondInputText: String
  ) -> AnyView {
    switch state {
    case .generateImageID:
      generateImageID(firstInputText: firstInputText, secondInputText: secondInputText)
    case .loginImageID:
      loginImageID(firstInputText: firstInputText)
    }
  }
  
  func generateImageID(
    firstInputText: String,
    secondInputText: String
  ) -> AnyView {
    var isValidation = true
    var bottomHelper: String?
    
    let passValidation = passValidation(password: firstInputText, confirm: secondInputText)
    if secondInputText.count > .zero {
      isValidation = passValidation.isValidation
      bottomHelper = passValidation.helperText
    }
    
    return AnyView(
      VStack(spacing: .s4) {
        InputView(.init(
          text: firstInputText,
          placeholder: OChatStrings.HighTechImageIDScreenLocalization
            .State.GenerateImageID.Input.First.placeholder,
          isSecureField: true,
          bottomHelper: nil,
          isError: false,
          isEnabled: true,
          isTextFieldFocused: false,
          isColorFocusBorder: true,
          keyboardType: .default,
          maxLength: 100,
          borderColor: SKStyleAsset.slate.swiftUIColor,
          style: .leftHelper(
            text: OChatStrings.HighTechImageIDScreenLocalization
              .State.GenerateImageID.Input.First.leftHelper
          ),
          rightButtonType: .clear,
          rightButtonAction: {},
          onTextFieldFocusedChange: { [weak self] isFocused, text in
            guard let self, !isFocused else {
              return
            }
            self.output?.changeFirstInputText(text: text)
          }
        ))
        .frame(height: .s14)
        
        InputView(.init(
          text: secondInputText,
          placeholder: OChatStrings.HighTechImageIDScreenLocalization
            .State.GenerateImageID.Input.Second.placeholder,
          isSecureField: true,
          bottomHelper: bottomHelper,
          isError: !isValidation,
          isEnabled: true,
          isTextFieldFocused: false,
          isColorFocusBorder: true,
          keyboardType: .default,
          maxLength: 100,
          borderColor: SKStyleAsset.slate.swiftUIColor,
          style: .leftHelper(
            text: OChatStrings.HighTechImageIDScreenLocalization
              .State.GenerateImageID.Input.Second.leftHelper
          ),
          rightButtonType: .clear,
          rightButtonAction: {},
          onTextFieldFocusedChange: { [weak self] isFocused, text in
            guard let self, !isFocused else {
              return
            }
            self.output?.changeSecondInputText(text: text)
          }
        ))
      }
        .padding(.top, .s2)
    )
  }
  
  func loginImageID(firstInputText: String) -> AnyView {
    AnyView(
      InputView(.init(
        text: firstInputText,
        placeholder: OChatStrings.HighTechImageIDScreenLocalization
          .State.LoginImageID.Input.First.placeholder,
        isSecureField: true,
        bottomHelper: nil,
        isError: false,
        isEnabled: true,
        isTextFieldFocused: false,
        isColorFocusBorder: true,
        keyboardType: .default,
        maxLength: 100,
        borderColor: SKStyleAsset.slate.swiftUIColor,
        style: .leftHelper(
          text: OChatStrings.HighTechImageIDScreenLocalization
            .State.LoginImageID.Input.First.leftHelper
        ),
        rightButtonType: .clear,
        rightButtonAction: {},
        onTextFieldFocusedChange: { [weak self] isFocused, text in
          guard let self, !isFocused else {
            return
          }
          self.output?.changeFirstInputText(text: text)
        }
      ))
    )
  }
  
  func passValidation(password: String, confirm: String) -> (isValidation: Bool, helperText: String?) {
    // Проверка на минимальное количество символов
    if password.count < 4 {
      return (
        false,
        OChatStrings.HighTechImageIDScreenLocalization
          .State.Validation.MinimalAmount.title("4")
      )
    }
    
    // Проверка на совпадение пароля и подтверждения
    if password != confirm {
      return (
        false,
        OChatStrings.HighTechImageIDScreenLocalization
          .State.Validation.PasswordMismatch.title
      )
    }
    
    // Все проверки пройдены
    return (true, nil)
  }
}

// MARK: - Constants

private enum Constants {}
