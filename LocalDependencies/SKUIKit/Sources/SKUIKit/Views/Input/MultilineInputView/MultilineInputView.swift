//
//  MultilineInputView.swift
//  SKUIKit
//
//  Created by Vladimir Stepanchikov on 3/26/24.
//

import SwiftUI
import SKStyle

public struct MultilineInputView: View {

  // MARK: - Private properties

  @State private var text: String = ""
  @State private var textFieldHeight: CGFloat = .s5
  @State private var inputViewHeight: CGFloat = .s5
  @FocusState private var isTextFieldFocused: Bool
  private var isTextFieldFocusedBinding: Bool
  private let model: InputViewModel
  private let impactFeedback = UIImpactFeedbackGenerator(style: .soft)

  // MARK: - Initialization

  /// Инициализатор для создания текстового поля
  /// - Parameters:
  ///   - model: Модель данных
  public init(_ model: InputViewModel) {
    self.model = model

    if let text = model.text {
      self.text = text
    }
    self.isTextFieldFocusedBinding = model.isTextFieldFocused
  }

  // MARK: - Body

  public var body: some View {
    VStack(spacing: .zero) {
      createInputView()
      createBottomHelperView()
    }
  }
}

// MARK: - Private

private extension MultilineInputView {
  func createInputView() -> AnyView {
    AnyView(
      ZStack {
        TapGestureView(
          style: .none,
          isImpactFeedback: false,
          touchesEnded: { isTextFieldFocused = true }
        ) {
          model.backgroundColor ?? SKStyleAsset.navy.swiftUIColor
        }
        .frame(height: max(textFieldHeight, inputViewHeight))
        VStack {
          HStack(alignment: .bottom, spacing: .zero) {
            // MARK: - leftHelper
            if case let .leftHelper(text) = model.style {
              Text(text)
                .font(.fancy.text.regularMedium)
                .foregroundColor(SKStyleAsset.constantSlate.swiftUIColor)
                .lineLimit(.max)
                .truncationMode(.tail)
                .padding(.trailing, .s2)
                .allowsHitTesting(false)
            }

            VStack(alignment: .leading, spacing: .zero) {
              // MARK: - topHelper
              if case let .topHelper(text) = model.style {
                Text(text)
                  .font(.fancy.text.regularMedium)
                  .foregroundColor(SKStyleAsset.constantSlate.swiftUIColor)
                  .lineLimit(.max)
                  .truncationMode(.tail)
                  .padding(.top, .s4)
                  .allowsHitTesting(false)
              }

              createTextField()
            }
            createRightButtonView()
              .padding(.bottom, .s2)
          }
        }
        .readSize { size in
          withAnimation {
            inputViewHeight = size.height
          }
        }
      }
        .frame(width: .infinity)
        .padding(.horizontal, .s4)
        .background(model.backgroundColor ?? SKStyleAsset.navy.swiftUIColor)
        .overlay(
          RoundedRectangle(cornerRadius: .s5)
            .stroke(
              getColorFocusBorder(),
              lineWidth: .s1 / 1.5
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: .s5))
        .onChange(of: isTextFieldFocusedBinding) { newValue in
          isTextFieldFocused = newValue
        }
        .onChange(of: isTextFieldFocused) { newValue in
          model.onTextFieldFocusedChange?(newValue, text)
        }
        .onChange(of: text) { newValue in
          model.onChange?(newValue)
        }
    )
  }

  func createRightButtonView() -> AnyView {
    switch model.rightButtonType {
    case .none:
      return AnyView(EmptyView())
    case .clear:
      if (!text.isEmpty && isTextFieldFocused) {
        return AnyView(
          Button(action: {
            text = ""
            impactFeedback.impactOccurred()
          }) {
            model.rightButtonType.image?
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(height: .s5)
              .foregroundColor(SKStyleAsset.constantSlate.swiftUIColor)
              .padding(.leading, .s3)
          }
        )
      } else {
        return AnyView(EmptyView())
      }
    case let .send(isEnabled):
      return AnyView(
        Button(action: {
          model.rightButtonAction?()
          impactFeedback.impactOccurred()
          text = ""
        }) {
          model.rightButtonType.image?
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: .s7)
            .foregroundColor(isEnabled ? SKStyleAsset.constantAzure.swiftUIColor : SKStyleAsset.constantSlate.swiftUIColor)
            .padding(.leading, .s7)
        }
          .disabled(!isEnabled)
          .opacity(text.isEmpty ? 0 : 1)
      )
    }
  }

  func createTextField() -> AnyView {
    AnyView(
      getTextField()
        .onChange(of: text) { newValue in
          if newValue.count > model.maxLength {
            text = String(newValue.prefix(model.maxLength))
          }
        }
        .autocorrectionDisabled(true)
        .keyboardType(model.keyboardType)
        .disabled(!model.isEnabled)
        .padding(.vertical, .s1)
        .focused($isTextFieldFocused)
        .font(model.textFont ?? .fancy.text.regular)
        .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
        .accentColor(model.isError ? SKStyleAsset.constantRuby.swiftUIColor : SKStyleAsset.constantAzure.swiftUIColor)
        .truncationMode(.tail)
        .padding(.bottom, .s4)
        .padding(.top, model.style.isTopHelper ? .zero : .s4)
    )
  }

  func getTextField() -> AnyView {
    return AnyView(
      ScrollView {
        ZStack {
          TextEditor(text: $text)
            .scrollContentBackground(.hidden)
            .background(model.backgroundColor ?? SKStyleAsset.navy.swiftUIColor)
            .frame(minHeight: .s5, maxHeight: .s20)
            .readSize { size in
              withAnimation {
                textFieldHeight = size.height
              }
            }
          if text.isEmpty {
            HStack {
              createPlaceholderView()
              Spacer()
            }
            .padding(.leading, .s1)
          }
        }
      }
        .frame(height: textFieldHeight)
        .scrollDisabled(true)
    )
  }

  func createBottomHelperView() -> AnyView {
    guard let bottomHelper = model.bottomHelper else {
      return AnyView(EmptyView())
    }

    return AnyView(
      HStack {
        Text("\(bottomHelper)")
          .font(model.bottomHelperFont ?? .fancy.text.small)
          .foregroundColor(
            model.isError ? SKStyleAsset.constantRuby.swiftUIColor : SKStyleAsset.constantSlate.swiftUIColor
          )
          .lineLimit(.max)
          .truncationMode(.tail)
          .padding(.trailing, .s2)
          .allowsHitTesting(false)
        Spacer()
      }
        .padding(.top, .s2)
        .padding(.horizontal, .s4)
    )
  }

  func getColorFocusBorder() -> Color {
    guard model.isColorFocusBorder else {
      return .clear
    }
    return model.isError ? SKStyleAsset.constantRuby.swiftUIColor :
    isTextFieldFocused ? SKStyleAsset.constantAzure.swiftUIColor : model.borderColor ?? Color.clear
  }

  func createPlaceholderView() -> Text {
    return Text(model.placeholder)
      .foregroundColor(SKStyleAsset.constantSlate.swiftUIColor.opacity(0.4))
  }
}

// MARK: - Preview
struct MultilineInputView_Previews: PreviewProvider {
  static var previews: some View {
    MultilineInputView(
      InputViewModel(
        text: "",
        placeholder: "Message",
        bottomHelper: "Helper text",
        isError: false,
        isEnabled: true,
        isTextFieldFocused: true,
        isColorFocusBorder: true,
        keyboardType: .default,
        maxLength: 100,
        textFont: nil,
        bottomHelperFont: nil,
        backgroundColor: nil,
        style: .none,
        rightButtonType: .send(isEnabled: true),
        rightButtonAction: {
          // TODO: -
        }
      )
    )
    .padding(.s4)
    .background(SKStyleAsset.onyx.swiftUIColor)
    .ignoresSafeArea(.all)
  }
}
