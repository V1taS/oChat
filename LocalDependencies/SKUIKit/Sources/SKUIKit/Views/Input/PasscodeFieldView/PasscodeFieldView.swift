//
//  PasscodeFieldView.swift
//
//
//  Created by Vitalii Sosin on 15.12.2023.
//

import SwiftUI
import SKStyle

/// Обработчик от Passcode
/// - Parameters:
///   - isSuccess: Присваиваем нашей вью Успех или Ошибка, когда успех или ошибка появляются подсказки снизу
///   - helperText: Подсказка снизу, если nil то не будет подсказки
///   - completion: Замыкание которое выполняется когда пользователь ввел все символы
public typealias PasscodeHandler = (
  _ completion: (_ isSuccess: Bool,
                 _ helperText: String?,
                 _ completion: (() -> Void)?) -> Void
) -> Void

public struct PasscodeFieldView: View {
  
  // MARK: - Private properties
  
  private var title: String
  @Binding private var pin: String
  @State private var helperText: String?
  @State private var isDisabled = false
  @State private var passcodeState: PasscodeFieldView.PasscodeState = .standart
  
  private let maxDigits: Int
  private let passcodeHandler: PasscodeHandler
  private var indices: [Int] { Array(.zero..<maxDigits) }
  
  // MARK: - Initialization
  
  /// Инициализатор
  /// - Parameters:
  ///   - title: Заголовок
  ///   - pin: Пин код
  ///   - maxDigits: Максимальное количество символов
  ///   - handler: Обработчик
  public init(
    title: String,
    pin: Binding<String>,
    maxDigits: Int = 4,
    passcodeHandler: @escaping PasscodeHandler
  ) {
    self.title = title
    self._pin = pin
    self.maxDigits = maxDigits
    self.passcodeHandler = passcodeHandler
  }
  
  // MARK: - Body
  
  public var body: some View {
    VStack(spacing: .s5) {
      Text(title)
        .font(.fancy.text.title)
        .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
        .multilineTextAlignment(.center)
        .lineLimit(2)
        .allowsHitTesting(false)
        .padding(.horizontal, .s6)
      
      ZStack {
        createPinDots()
      }
      
      if let helperText {
        Text(helperText)
          .font(.fancy.text.regularMedium)
          .foregroundColor(passcodeState.color)
          .multilineTextAlignment(.center)
          .lineLimit(2)
          .allowsHitTesting(false)
          .padding(.horizontal, .s6)
          .frame(height: .s15)
      } else {
        Text("")
          .font(.fancy.text.regularMedium)
          .foregroundColor(passcodeState.color)
          .multilineTextAlignment(.center)
          .lineLimit(2)
          .allowsHitTesting(false)
          .padding(.horizontal, .s6)
          .frame(height: .s15)
      }
    }
    .onChange(of: pin) { _ in
      guard pin.count <= maxDigits else {
        return
      }
      submitPin()
    }
  }
}

// MARK: - Private

private extension PasscodeFieldView {
  func triggerHapticFeedback(_ type: UINotificationFeedbackGenerator.FeedbackType) {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(type)
  }
  
  func createPinDots() -> AnyView {
    AnyView(
      HStack(spacing: .zero) {
        Spacer()
        ForEach(indices, id: \.self) { index in
          Image(systemName: getImageName(at: index))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: .s5)
            .padding(.horizontal, .s4)
            .foregroundColor(passcodeState.color)
        }
        Spacer()
      }
    )
  }
  
  func finishSetPin(_ completion: (() -> Void)?) {
    Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
      pin = ""
      isDisabled = false
      passcodeState = .standart
      self.helperText = nil
      completion?()
    }
  }
  
  func submitPin() {
    guard !pin.isEmpty else {
      return
    }
    
    if pin.count == maxDigits {
      isDisabled = true
      passcodeHandler { isSuccess, helperText, completion  in
        if isSuccess {
          self.helperText = helperText
          passcodeState = .success
          finishSetPin(completion)
          triggerHapticFeedback(.success)
        } else {
          self.helperText = helperText
          passcodeState = .failure
          finishSetPin(completion)
          triggerHapticFeedback(.error)
        }
      }
      return
    }
  }
  
  func getImageName(at index: Int) -> String {
    if index >= self.pin.count {
      return Constants.circle
    }
    return Constants.circleFill
  }
}

// MARK: - Constants

private enum Constants {
  static let circle = "circle"
  static let circleFill = "circle.fill"
}

// MARK: - Preview

struct PasscodeView_Previews: PreviewProvider {
  static var previews: some View {
    PasscodeFieldView(
      title: "Pass Code",
      pin: .constant(""),
      maxDigits: 4,
      passcodeHandler: { completion in
        completion(true, "Helper text", {})
      }
    )
    .background(Color.black)
  }
}
