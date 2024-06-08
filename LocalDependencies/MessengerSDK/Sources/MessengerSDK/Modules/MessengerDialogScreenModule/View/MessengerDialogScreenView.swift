//
//  MessengerDialogScreenView.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions
import Lottie

struct MessengerDialogScreenView: View {
  
  // MARK: - Internal properties
  @StateObject
  var presenter: MessengerDialogScreenPresenter
  
  // MARK: - Body
  
  var body: some View {
    VStack(spacing: .zero) {
      getContent()
    }
    .padding(.horizontal, .s4)
    .padding(.bottom, .s4)
  }
}

// MARK: - Private

private extension MessengerDialogScreenView {
  func getContent() -> AnyView {
    if presenter.stateContactModel.encryptionPublicKey == nil {
      return AnyView(keyExchangeInProgressView())
    } else {
      return AnyView(readyToChatView())
    }
  }
  
  func readyToChatView() -> some View {
    VStack {
      ScrollView(.vertical, showsIndicators: false) {
        LazyVStack(spacing: .zero) {
          ForEach(presenter.stateMessengeModels, id: \.id) { messengeModel in
            if messengeModel.messageType == .own {
              HStack(spacing: .zero) {
                Spacer()
                createMessageView(
                  isRequested: !presenter.isValidationRequested(),
                  messageType: messengeModel.messageType,
                  message: messengeModel.message
                )
              }
              .padding(.top, .s4)
            }
            
            if messengeModel.messageType == .received {
              HStack(spacing: .zero) {
                createMessageView(
                  isRequested: !presenter.isValidationRequested(),
                  messageType: messengeModel.messageType,
                  message: messengeModel.message
                )
                Spacer()
              }
              .padding(.top, .s4)
            }
          }
        }
      }
      .padding(.bottom, .s4)
      .if(presenter.stateMessengeModels.last?.messageStatus == .inProgress) { view in
        view
          .overlay {
            ZStack {
              RoundedRectangle(cornerRadius: 20)
                .fill(SKStyleAsset.onyx.swiftUIColor.opacity(0.9))
                .blur(radius: 10)
              
              VStack(spacing: .s4) {
                createChatingAnimation()
                
                Text("Ожидаем, когда контакт получит сообщение.")
                  .font(.fancy.text.largeTitle)
                  .multilineTextAlignment(.center)
                  .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
                
                Text("\(presenter.stateChatingTitle)")
                  .font(.fancy.text.regular)
                  .foregroundColor(SKStyleAsset.constantSlate.swiftUIColor)
                
                Spacer()
              }
              .padding()
            }
          }
      }
      
      Spacer()
      
      createSendMessageView()
    }
  }
  
  func keyExchangeInProgressView() -> some View {
    VStack(spacing: .s4) {
      createKeyExchangeAnimation()
      
      Text("Ждем обмен ключами с контактом")
        .font(.fancy.text.largeTitle)
        .multilineTextAlignment(.center)
        .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
      
      Text("\(presenter.stateKeyExchangeTitle)")
        .font(.fancy.text.regular)
        .foregroundColor(SKStyleAsset.constantSlate.swiftUIColor)
      
      Spacer()
      
      if presenter.stateKeyExchangeIsShow {
        MainButtonView(text: "Запросить переписку") {
          presenter.sendInitiateChatFromDialog()
        }
      }
    }
  }
  
  func createSendMessageView() -> some View {
    MultilineInputView(
      InputViewModel(
        text: presenter.stateInputMessengeText,
        placeholder: presenter.getPlaceholder(),
        bottomHelper: presenter.stateBottomHelper,
        isError: presenter.stateIsErrorInputText,
        isEnabled: presenter.stateIsEnabledInputText,
        maxLength: presenter.stateMaxLengthInputText,
        rightButtonType: .send(isEnabled: presenter.stateIsEnabledRightButton),
        rightButtonAction: {
          presenter.sendMessage()
        },
        onChange: { newMessage in
          presenter.stateInputMessengeText = newMessage
        }
      )
    )
  }
  
  func createMessageView(
    isRequested: Bool,
    messageType: MessengeModel.MessageType,
    message: String
  ) -> some View {
    Text(isRequested ? "Запрос на начало переписки" : message)
      .font(.fancy.text.regular)
      .foregroundColor(SKStyleAsset.constantGhost.swiftUIColor)
      .multilineTextAlignment(.leading)
      .lineLimit(.max)
      .truncationMode(.middle)
      .roundedEdge(
        backgroundColor: messageType == .own ? SKStyleAsset.azure.swiftUIColor : SKStyleAsset.navy.swiftUIColor
      )
      .allowsHitTesting(false)
  }
  
  func createKeyExchangeAnimation() -> some View {
    VStack {
      LottieView(
        animation: .asset(
          MessengerSDKAsset.keyExchangeAnimation.name,
          bundle: MessengerSDKResources.bundle
        )
      )
      .resizable()
      .looping()
      .aspectRatio(contentMode: .fit)
    }
  }
  
  func createChatingAnimation() -> some View {
    VStack {
      LottieView(
        animation: .asset(
          MessengerSDKAsset.p2pChating.name,
          bundle: MessengerSDKResources.bundle
        )
      )
      .resizable()
      .looping()
      .aspectRatio(contentMode: .fit)
    }
  }
}

// MARK: - Preview

struct MessengerDialogScreenView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      MessengerDialogScreenAssembly().createModule(
        dialogModel: .mock(),
        services: ApplicationServicesStub()
      ).viewController
    }
  }
}
