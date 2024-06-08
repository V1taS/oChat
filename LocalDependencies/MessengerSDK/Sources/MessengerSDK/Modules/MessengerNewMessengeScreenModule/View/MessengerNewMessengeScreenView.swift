//
//  MessengerNewMessengeScreenView.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions

struct MessengerNewMessengeScreenView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: MessengerNewMessengeScreenPresenter
  
  // MARK: - Body
  
  var body: some View {
    VStack(spacing: .zero) {
      ScrollView(showsIndicators: false) {
        createToWhomInputView()
          .padding(.top, .s4)
        
        createSecretChatInviteView()
          .padding(.top, .s10)
      }
      
      Spacer()
      
      MainButtonView(
        text: "Request to chat",
        isEnabled: presenter.validateSendButton(),
        style: presenter.validateSendButton() ? .primary : .secondary
      ) {
        presenter.sendInitiateChat()
      }
    }
    .padding(.horizontal, .s4)
    .padding(.bottom, .s4)
  }
}

// MARK: - Private

private extension MessengerNewMessengeScreenView {
  func createSecretChatInviteView() -> some View {
    VStack(alignment: .leading, spacing: .s5) {
      HStack { Spacer() }
      Text("You invited contact to join a Secret Chat.")
        .font(.fancy.text.title)
        .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
        .padding(.horizontal, .s4)
      
      
      VStack(alignment: .leading, spacing: .s4) {
        HStack {
          Image(systemName: "lock.fill")
          Text("Use end-to-end encryption")
            .font(.fancy.text.regularMedium)
            .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
        }
        
        HStack {
          Image(systemName: "lock.fill")
          Text("Leave no trace on our servers")
            .font(.fancy.text.regularMedium)
            .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
        }
        
        HStack {
          Image(systemName: "lock.fill")
          Text("Have a self-destruct timer")
            .font(.fancy.text.regularMedium)
            .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
        }
        
        HStack {
          Image(systemName: "lock.fill")
          Text("Do not allow forwarding")
            .font(.fancy.text.regularMedium)
            .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
        }
      }
      .padding(.bottom, .s4)
      .padding(.horizontal, .s4)
    }
  }
  
  func createToWhomInputView() -> some View {
    MultilineInputView(.init(
      text: presenter.recipientAddress,
      placeholder: "",
      bottomHelper: "Введите адрес получателя",
      isError: false,
      isEnabled: true,
      isTextFieldFocused: false,
      isColorFocusBorder: true,
      keyboardType: .default,
      maxLength: 100,
      style: .none,
      rightButtonType: .clear,
      onChange: { _ in
#warning("TODO: - Что то напечаталось")
      },
      onTextFieldFocusedChange: { isFocused, text in
        if !isFocused {
          presenter.recipientAddress = text
        }
      }
    ))
  }
}

// MARK: - Preview

struct MessengerNewMessengeScreenView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      MessengerNewMessengeScreenAssembly()
        .createModule(
          services: ApplicationServicesStub(),
          contactAdress: nil
        )
        .viewController
    }
  }
}
