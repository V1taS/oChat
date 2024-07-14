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
import ExyteChat
import ExyteMediaPicker

struct MessengerDialogScreenView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: MessengerDialogScreenPresenter
  
  // MARK: - Private properties
  
  // MARK: - Body
  
  var body: some View {
    VStack(spacing: .zero) {
      getContent()
    }
  }
}

// MARK: - Private

private extension MessengerDialogScreenView {
  func getContent() -> AnyView {
    if presenter.isInitialAddressEntryState() {
      return AnyView(createInitialAddressView())
    }
    if presenter.isRequestChatState() {
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
      backgroundColor = SKStyleAsset.constantAzure.swiftUIColor
    case .received:
      backgroundColor = SKStyleAsset.constantNavy.swiftUIColor
    default:
      backgroundColor = SKStyleAsset.constantAmberGlow.swiftUIColor
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
}

// MARK: - Private Ready To Chat

private extension MessengerDialogScreenView {
  @ViewBuilder
  func readyToChatView() -> some View {
    if presenter.isInitialWaitConfirmState() {
      ChatView(
        messages: presenter.stateMessengeModels, 
        placeholder: "",
        isDownloadAvailability: presenter.stateIsDownloadAvailability,
        onChange: { _ in },
        didSendMessage: { _ in },
        inputViewBuilder: { _, _, _, _, _, _ in
          MainButtonView(
            text: presenter.stateIsCanResendInitialRequest
            ? MessengerSDKStrings.MessengerDialogScreenLocalization.sendRequest
            : "\(MessengerSDKStrings.MessengerDialogScreenLocalization.sendRequest)"
            + " \(presenter.stateSecondsUntilResendInitialRequestAllowed)"
            + " \(MessengerSDKStrings.MessengerDialogScreenLocalization.seconds)",
            isEnabled: presenter.stateIsCanResendInitialRequest,
            style: .primary,
            action: {
              presenter.sendInitiateChatFromDialog(toxAddress: nil)
              presenter.startScheduleResendInitialRequest()
            }
          )
          .padding(.horizontal, .s4)
          .padding(.top, .s4)
        }
      )
      .showMessageTimeView(false)
      .showDateHeaders(showDateHeaders: false)
    } else if presenter.stateContactModel.status == .offline {
      ChatView(
        messages: presenter.stateMessengeModels,
        placeholder: "",
        isDownloadAvailability: presenter.stateIsDownloadAvailability,
        onChange: { _ in },
        didSendMessage: { _ in },
        inputViewBuilder: { _, _, _, _, _, _ in
          MainButtonView(
            text: presenter.stateIsAskToComeContact ?
            "Позвать контакт" :
              "Позвать контакт через \(presenter.stateSecondsUntilAskToComeContactAllowed) сек.",
            isEnabled: presenter.stateIsAskToComeContact,
            style: .primary,
            action: {
              presenter.sendPushNotification()
              presenter.startAskToComeContactTimer()
            }
          )
          .padding(.horizontal, .s4)
          .padding(.top, .s4)
        }
      )
      .showMessageTimeView(false)
      .showDateHeaders(showDateHeaders: false)
    } else {
      ChatView(
        messages: presenter.stateMessengeModels,
        placeholder: presenter.getMainPlaceholder(),
        isDownloadAvailability: presenter.stateIsDownloadAvailability,
        onChange: { newValue in
          presenter.setUserIsTyping(text: newValue)
        },
        didSendMessage: { draft in
          Task {
            if draft.medias.isEmpty && draft.recording == nil {
              await presenter.sendMessage(
                messenge: draft.text,
                replyMessageText: draft.replyMessage?.text
              )
            } else {
              await presenter.sendMessage(
                messenge: draft.text,
                medias: draft.medias,
                recording: draft.recording,
                replyMessageText: draft.replyMessage?.text
              )
            }
          }
        },
        onImageSave: { url in
          presenter.saveImageToGallery(url)
        },
        onVideoSave: { url in
          presenter.saveVideoToGallery(url)
        }
      )
      .setAvailableInput(.full)
      .showMessageTimeView(false)
      .showDateHeaders(showDateHeaders: false)
      .setMediaPickerSelectionParameters(
        .init(
          mediaType: .photoAndVideo,
          selectionStyle: .checkmark,
          selectionLimit: 10,
          showFullscreenPreview: false
        )
      )
      .messageUseMarkdown(messageUseMarkdown: true)
      .showMessageMenuOnLongPress(true)
      .showNetworkConnectionProblem(true)
      .assetsPickerLimit(assetsPickerLimit: 10)
      .enableLoadMore(offset: presenter.stateShowMessengeMaxCount) { message in
        presenter.loadMoreMessage(before: message)
      }
      .messageUseMarkdown(messageUseMarkdown: true)
      .mediaPickerTheme()
    }
  }
}

// MARK: - Private Initial

private extension MessengerDialogScreenView {
  func createInitialAddressView() -> some View {
    ChatView(
      messages: presenter.stateMessengeModels, 
      placeholder: presenter.getInitialPlaceholder(),
      isDownloadAvailability: presenter.stateIsDownloadAvailability,
      onChange: { _ in },
      didSendMessage: { draft in
        DispatchQueue.main.async {
          presenter.sendInitiateChatFromDialog(toxAddress: draft.text)
          presenter.startScheduleResendInitialRequest()
        }
      },
      messageBuilder: { _, _, _ in
        AnyView(
          informationView(model: presenter.getInitialHintModel())
        )
        .padding(.bottom, .s4)
      }
    )
    .setAvailableInput(.textOnly)
    .showMessageTimeView(false)
    .showDateHeaders(showDateHeaders: false)
    .showMessageMenuOnLongPress(false)
    .showNetworkConnectionProblem(true)
    .mediaPickerTheme()
  }
  
  func informationView(model: MessengerDialogHintModel) -> some View {
    VStack {
      ScrollView(.vertical, showsIndicators: false) {
        VStack(spacing: .zero) {
          if let note = model.note, presenter.stateShowInitialTips {
            TipsView(
              .init(
                text: note,
                style: .attention,
                isSelectableTips: false,
                actionTips: {},
                isCloseButton: true,
                closeButtonAction: {
                  presenter.stateShowInitialTips.toggle()
                }
              )
            )
            .padding(.bottom, .s10)
          }
          
          createHeaderView(model: model)
          createInformationBloksView(model: model)
            .padding(.top, .s12)
        }
        .padding(.top, .s2)
      }
      
      Spacer()
      
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
        .padding(.horizontal, .s4)
      }
    }
    .onTapGesture {
      dismissKeyboard()
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
        .offset(y: -10)
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
        .foregroundColor(SKStyleAsset.constantAzure.swiftUIColor)
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
          .foregroundColor(SKStyleAsset.constantSlate.swiftUIColor)
          .multilineTextAlignment(.leading)
          .allowsHitTesting(false)
          .padding(.horizontal, .s4)
      }
      Spacer()
    }
    .padding(.horizontal, .s4)
  }
  
  func dismissKeyboard() {
    UIApplication.shared.sendAction(
      #selector(UIResponder.resignFirstResponder),
      to: nil,
      from: nil,
      for: nil
    )
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
