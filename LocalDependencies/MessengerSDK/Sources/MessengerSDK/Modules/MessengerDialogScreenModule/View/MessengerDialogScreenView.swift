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
import Combine
import Foundation

struct MessengerDialogScreenView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: MessengerDialogScreenPresenter
  
  // MARK: - Private properties
  
  @State private var keyboardHeight: CGFloat = .zero
  @State private var keyboardCancellable: AnyCancellable?
  
  // MARK: - Body
  
  var body: some View {
    VStack(spacing: .zero) {
      getContent()
    }
    .padding(.horizontal, .s4)
    .padding(.bottom, .s4)
    .onAppear {
      subscribeToKeyboardNotifications()
    }
    .onDisappear {
      unsubscribeFromKeyboardNotifications()
    }
  }
}

// MARK: - Private

private extension MessengerDialogScreenView {
  func getContent() -> AnyView {
    if presenter.stateContactModel.status == .initialChat && 
        (presenter.stateContactModel.toxAddress.isNilOrEmpty || presenter.stateIsDeeplinkAdress) {
      return AnyView(informationView(model: presenter.getInitialHintModel()))
    }
    if presenter.stateContactModel.status == .requestChat {
      return AnyView(informationView(model: presenter.getRequestHintModel()))
    }
    return AnyView(readyToChatView())
  }
  
  func createMessageView(
    messageType: MessengeModel.MessageType,
    message: String
  ) -> some View {
    let backgroundColor: Color
    let foregroundColor: Color
    
    switch messageType {
    case .own:
      backgroundColor = SKStyleAsset.azure.swiftUIColor
    case .received:
      backgroundColor = SKStyleAsset.navy.swiftUIColor
    case .system:
      backgroundColor = SKStyleAsset.amberGlow.swiftUIColor
    }
    
    return Text(message)
      .font(.fancy.text.regular)
      .foregroundColor(SKStyleAsset.constantGhost.swiftUIColor)
      .multilineTextAlignment(.leading)
      .lineLimit(.max)
      .truncationMode(.middle)
      .roundedEdge(backgroundColor: backgroundColor)
      .allowsHitTesting(false)
  }
  
  func createChatFieldView(isInitialState: Bool) -> some View {
    let isValidate = isInitialState ? presenter.isInitialChatValidation() : presenter.isChatValidation()
    
    return HStack(spacing: .s4) {
      ChatFieldView(
        isInitialState ? "\(presenter.getInitialPlaceholder())" : "\(presenter.getMainPlaceholder())",
        message: isInitialState ? $presenter.stateContactAdress : $presenter.stateInputMessengeText,
        maxLength: isInitialState ? presenter.stateContactAdressMaxLength : presenter.stateInputMessengeTextMaxLength,
        onChange: { newvalue in
          // TODO: -
        },
        header: {
          EmptyView()
        },
        footer: {
          EmptyView()
        }
      )
      .chatFieldStyle(.capsule)
      
      Button(action: {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        
        if isInitialState {
          presenter.sendInitiateChatFromDialog()
        } else {
          presenter.sendMessage()
        }
      }) {
        Image(systemName: "arrow.up.circle.fill")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(height: .s7)
          .foregroundColor(isValidate ? SKStyleAsset.azure.swiftUIColor : SKStyleAsset.slate.swiftUIColor)
          .opacity(isValidate ? 1 : 0.5)
      }
      .disabled(!isValidate)
    }
  }
  
  func subscribeToKeyboardNotifications() {
    keyboardCancellable = Publishers.Merge(
      NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification),
      NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
    )
    .compactMap { notification in
      if notification.name == UIResponder.keyboardWillShowNotification,
         let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
        return keyboardFrame.height
      } else {
        return CGFloat(0)
      }
    }
    .assign(to: \.keyboardHeight, on: self)
  }
  
  func unsubscribeFromKeyboardNotifications() {
    keyboardCancellable?.cancel()
    keyboardCancellable = nil
  }
}

// MARK: - Private Ready To Chat

private extension MessengerDialogScreenView {
  func readyToChatView() -> some View {
    ScrollViewReader { scrollViewProxy in
      VStack {
        ScrollView(.vertical, showsIndicators: false) {
          LazyVStack(spacing: .zero) {
            ForEach(presenter.stateMessengeModels, id: \.id) { messengeModel in
              if messengeModel.messageType == .own {
                HStack(spacing: .zero) {
                  Spacer()
                  createMessageView(
                    messageType: messengeModel.messageType,
                    message: messengeModel.message
                  )
                }
                .padding(.top, .s4)
                .id(messengeModel.id)
              }
              
              if messengeModel.messageType == .received {
                HStack(spacing: .zero) {
                  createMessageView(
                    messageType: messengeModel.messageType,
                    message: messengeModel.message
                  )
                  Spacer()
                }
                .padding(.top, .s4)
                .id(messengeModel.id)
              }
              
              if messengeModel.messageType == .system {
                TipsView(
                  .init(
                    text: messengeModel.message,
                    style: .success,
                    isSelectableTips: false,
                    actionTips: {},
                    isCloseButton: true,
                    closeButtonAction: {
                      presenter.removeMessage(id: messengeModel.id)
                    }
                  )
                )
                .padding(.top, .s4)
                .id(messengeModel.id)
              }
            }
          }
          .onChange(of: presenter.stateMessengeModels) { _ in
            scrollViewProxy.scrollTo(presenter.stateMessengeModels.last?.id, anchor: .bottom)
          }
          .onChange(of: keyboardHeight) { _ in
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
              withAnimation {
                scrollViewProxy.scrollTo(presenter.stateMessengeModels.last?.id, anchor: .bottom)
              }
            }
          }
        }
        .padding(.bottom, .s4)
        
        createChatFieldView(isInitialState: false)
      }
      .onAppear {
        scrollViewProxy.scrollTo(presenter.stateMessengeModels.last?.id, anchor: .bottom)
      }
    }
  }
}

// MARK: - Private Initial

private extension MessengerDialogScreenView {
  func informationView(model: MessengerDialogHintModel) -> some View {
    VStack {
      ScrollView(.vertical, showsIndicators: false) {
        VStack(spacing: .zero) {
          createHeaderView(model: model)
          createInformationBloksView(model: model)
            .padding(.top, .s12)
        }
        .padding(.top, .s2)
      }
      
      Spacer()
      
      if presenter.stateContactModel.status == .initialChat {
        createChatFieldView(isInitialState: true)
      }
      if presenter.stateContactModel.status == .requestChat {
        VStack(spacing: .s4) {
          MainButtonView(
            text: model.buttonTitle,
            style: .primary) {
              presenter.confirmRequestForDialog()
            }
          
          MainButtonView(
            text: presenter.getRequestButtonCancelTitle(),
            style: .critical) {
              presenter.cancelRequestForDialog()
            }
        }
      }
    }
  }
  
  func createHeaderView(model: MessengerDialogHintModel) -> some View {
    return VStack(spacing: .zero) {
      if let lottieAnimationName = model.lottieAnimationName {
        LottieView(animation: .asset(
          lottieAnimationName,
          bundle: MessengerSDKResources.bundle
        ))
        .resizable()
        .looping()
        .aspectRatio(contentMode: .fit)
        .frame(width: 300, height: 300)
        .offset(y: -20)
      }
      
      TitleAndSubtitleView(
        title: .init(text: model.headerTitle),
        description: .init(text: model.headerDescription),
        style: .standart
      )
      .padding(.horizontal, .s4)
    }
  }
  
  func createInformationBloksView(model: MessengerDialogHintModel) -> some View {
    return VStack(spacing: .s4) {
      createInformationBlokView(
        title: model.oneTitle,
        description: model.oneDescription,
        systemImageName: model.oneSystemImageName
      )
      
      createInformationBlokView(
        title: model.twoTitle,
        description: model.twoDescription,
        systemImageName: model.twoSystemImageName
      )
      
      createInformationBlokView(
        title: model.threeTitle,
        description: model.threeDescription,
        systemImageName: model.threeSystemImageName
      )
    }
  }
  
  func createInformationBlokView(
    title: String,
    description: String,
    systemImageName: String
  ) -> some View {
    HStack(alignment: .center, spacing: .zero) {
      Image(systemName: systemImageName)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .foregroundColor(SKStyleAsset.azure.swiftUIColor)
        .frame(width: 30, height: 30)
        .allowsHitTesting(false)
      
      VStack(alignment: .leading, spacing: .s1) {
        Text(title)
          .font(.fancy.text.regularMedium)
          .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
          .multilineTextAlignment(.leading)
          .allowsHitTesting(false)
          .padding(.horizontal, .s4)
        
        Text(description)
          .font(.fancy.text.small)
          .foregroundColor(SKStyleAsset.slate.swiftUIColor)
          .multilineTextAlignment(.leading)
          .allowsHitTesting(false)
          .padding(.horizontal, .s4)
      }
      Spacer()
    }
    .padding(.horizontal, .s4)
  }
}

// MARK: - Preview


struct MessengerDialogScreenView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      MessengerDialogScreenAssembly().createModule(
        dialogModel: .mock(),
        contactAdress: nil,
        services: ApplicationServicesStub()
      ).viewController
    }
  }
}
