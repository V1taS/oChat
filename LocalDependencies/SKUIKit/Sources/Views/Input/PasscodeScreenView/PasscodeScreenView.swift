//
//  PasscodeScreenView.swift
//
//
//  Created by Vitalii Sosin on 20.01.2024.
//

import SwiftUI
import SKStyle

public struct PasscodeScreenView: View {
  
  // MARK: - Private properties
  
  @State private var pin: String = ""
  private let title: String
  private let maxDigits: Int
  private let isEnabledKeyboard: Bool
  private let passcodeHandler: PasscodeHandler
  private let onChangeAccessCode: ((_ code: String) -> Void)?
  
  // MARK: - Initialization
  
  /// Инициализатор
  /// - Parameters:
  ///   - title: Заголовок
  ///   - maxDigits: Максимальное количество пароля
  ///   - passcodeHandler: Замыкание которое выполняется когда пользователь ввел все символы
  ///   - onChangeAccessCode: Акшен на каждый ввод с клавиатуры
  public init(
    title: String,
    maxDigits: Int,
    isEnabledKeyboard: Bool = true,
    passcodeHandler: @escaping PasscodeHandler,
    onChangeAccessCode: ((String) -> Void)? = nil
  ) {
    self.title = title
    self.maxDigits = maxDigits
    self.isEnabledKeyboard = isEnabledKeyboard
    self.passcodeHandler = passcodeHandler
    self.onChangeAccessCode = onChangeAccessCode
  }
  
  // MARK: - Body
  
  public var body: some View {
    VStack(spacing: .s6) {
      createEnterPasscodeView()
    }
  }
}

// MARK: - Private

private extension PasscodeScreenView {
  func createEnterPasscodeView() -> some View {
    VStack(spacing: .zero) {
      Spacer()
      PasscodeFieldView(
        title: title,
        pin: $pin,
        maxDigits: maxDigits,
        passcodeHandler: passcodeHandler
      )
      
      Spacer()
      
      KeyboardView(value: $pin, isEnabled: isEnabledKeyboard, onChange: { newValue in
        guard newValue.count <= maxDigits else {
          return
        }
        pin = newValue
        onChangeAccessCode?(newValue)
      })
      .padding(.bottom, .s10)
    }
  }
}

// MARK: - Preview

struct PasscodeScreenView_Previews: PreviewProvider {
  static var previews: some View {
    ZStack {
      HStack {
        SKStyleAsset.onyx.swiftUIColor
      }
      
      VStack {
        Spacer()
        
        HStack {
          PasscodeScreenView(
            title: "Введите пароль",
            maxDigits: 4,
            isEnabledKeyboard: true,
            passcodeHandler: { completion in }
          )
        }
      }
      .padding(.bottom, .s20)
    }
    .background(SKStyleAsset.onyx.swiftUIColor)
    .ignoresSafeArea(.all)
  }
}
