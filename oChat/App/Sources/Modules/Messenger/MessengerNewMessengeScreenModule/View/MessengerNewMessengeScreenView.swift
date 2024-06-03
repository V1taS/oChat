//
//  MessengerNewMessengeScreenView.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI

struct MessengerNewMessengeScreenView: View {

  // MARK: - Internal properties
  @State private var message = ""
  @StateObject
  var presenter: MessengerNewMessengeScreenPresenter

  // MARK: - Body

  var body: some View {
    VStack(spacing: .zero) {
      createToWhomInputView()
        .frame(height: .s16)
        .padding(.top, .s4)
      Spacer()
      createSendMessengeView()
    }
    .padding(.horizontal, .s4)
    .padding(.bottom, .s4)
  }
}

// MARK: - Private

private extension MessengerNewMessengeScreenView {
  func createToWhomInputView() -> some View {
    InputView(.init(
      text: "",
      placeholder: "",
      bottomHelper: nil,
      isError: false,
      isEnabled: true,
      isTextFieldFocused: false,
      isColorFocusBorder: true,
      keyboardType: .default,
      maxLength: 100,
      style: .leftHelper(text: "Кому:"),
      rightButtonType: .clear,
      onChange: { _ in
#warning("TODO: - Что то напечаталось")
      },
      onTextFieldFocusedChange: { isFocused, text in
        if !isFocused {
          presenter.recipientName = text
        }
      }
    ))
  }

  func createSendMessengeView() -> some View {
    MultilineInputView(
      InputViewModel(
        text: "",
        placeholder: "Message",
        bottomHelper: presenter.costOfSendingMessage,
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
          presenter.openNewMessageDialogScreen(
            messageModel: MessengerDialogModel.MessengeModel(messengeType: .own, message: message, date: Date())
          )
        },
        onChange: { newMessage in
          message = newMessage
        }
      )
    )
  }
}

// MARK: - Preview

struct MessengerNewMessengeScreenView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      MessengerNewMessengeScreenAssembly()
        .createModule(senderName: "Volodya", costOfSendingMessage: "Для меня бесплатно")
        .viewController
    }
  }
}
