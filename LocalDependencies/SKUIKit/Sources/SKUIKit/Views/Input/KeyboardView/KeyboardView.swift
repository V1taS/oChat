//
//  KeyboardView.swift
//
//
//  Created by Vitalii Sosin on 15.12.2023.
//

import SwiftUI
import SKStyle

public struct KeyboardView: View {
  
  // MARK: - Private properties
  
  @Binding private var value: String
  private var isEnabled: Bool
  private let buttonSize: CGFloat = .s17
  private let onChange: ((_ newValue: String) -> Void)?
  
  // MARK: - Initialization
  
  /// Инициализатор
  /// - Parameters:
  ///   - value: Пин код
  ///   - isEnabled: Клавиатура включена
  ///   - onChange: Акшен на каждый ввод с клавиатуры
  public init(
    value: Binding<String>,
    isEnabled: Bool,
    onChange: ((_ newValue: String) -> Void)?
  ) {
    self._value = value
    self.isEnabled = isEnabled
    self.onChange = onChange
  }
  
  // MARK: - Body
  
  public var body: some View {
    VStack(spacing: .s6) {
      createNumberLine(numbers: Constants.firstLine)
      createNumberLine(numbers: Constants.secondLine)
      createNumberLine(numbers: Constants.thirdLine)
      createNumberLine(numbers: Constants.fourthLine)
    }
    .onChange(of: value) { newValue in
      self.onChange?(newValue)
    }
  }
}

// MARK: - Private

private extension KeyboardView {
  func createButton(title: String, action: @escaping () -> Void) -> AnyView {
    if title == "" {
      return AnyView(
        Color.clear
          .frame(width: buttonSize, height: buttonSize)
          .clipShape(Circle())
      )
    }
    
    return AnyView(
      TapGestureView(
        style: .flash,
        isSelectable: isEnabled,
        touchesEnded: action
      ) {
        ZStack {
          SKStyleAsset.constantSlate.swiftUIColor.opacity(0.05)
          
          Text(title)
            .font(.fancy.text.largeTitle)
            .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
            .fontWeight(.bold)
        }
        .frame(width: buttonSize, height: buttonSize)
        .clipShape(Circle())
      }
    )
  }
  
  func createNumberLine(numbers: [String]) -> AnyView {
    AnyView(
      HStack(spacing: .zero) {
        ForEach(Array(numbers.enumerated()), id: \.offset) { _, number in
          switch number {
          case Constants.spacer:
            Spacer()
          case Constants.remove:
            createRemoveButton {
              if !value.isEmpty {
                value.removeLast()
              }
            }
          default:
            createButton(title: number) {
              value.append(number)
            }
          }
        }
      }
    )
  }
  
  func createRemoveButton(action: @escaping () -> Void) -> AnyView {
    AnyView(
      TapGestureView(
        style: .flash,
        isSelectable: isEnabled,
        touchesEnded: action
      ) {
        ZStack {
          SKStyleAsset.constantSlate.swiftUIColor.opacity(0.05)
          
          Image(systemName: "delete.backward")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: .s7, height: .s7)
            .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
        }
        .frame(width: buttonSize, height: buttonSize)
        .clipShape(Circle())
      }
    )
  }
}


// MARK: - Constants

private enum Constants {
  static let spacer = "Spacer"
  static let remove = "Remove"
  static let firstLine: [String] = [
    Constants.spacer,
    "1",
    Constants.spacer,
    "2",
    Constants.spacer,
    "3",
    Constants.spacer
  ]
  static let secondLine: [String] = [
    Constants.spacer,
    "4",
    Constants.spacer,
    "5",
    Constants.spacer,
    "6",
    Constants.spacer
  ]
  static let thirdLine: [String] = [
    Constants.spacer,
    "7",
    Constants.spacer,
    "8",
    Constants.spacer,
    "9",
    Constants.spacer
  ]
  static let fourthLine: [String] = [
    Constants.spacer,
    "",
    Constants.spacer,
    "0",
    Constants.spacer,
    Constants.remove,
    Constants.spacer
  ]
}

// MARK: - Preview

struct KeyboardView_Previews: PreviewProvider {
  static var previews: some View {
    ZStack {
      HStack {
        SKStyleAsset.onyx.swiftUIColor
      }
      
      VStack {
        Spacer()
        
        HStack {
          KeyboardView(
            value: .constant(""), 
            isEnabled: true,
            onChange: { newValue in }
          )
        }
      }
      .padding(.bottom, .s20)
    }
    .background(SKStyleAsset.onyx.swiftUIColor)
    .ignoresSafeArea(.all)
  }
}
