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
import SKChat

typealias InputViewBuilder = ((
  Binding<String>,
  InputViewAttachments,
  InputViewState,
  InputViewStyle,
  @escaping (InputViewAction) -> Void,
  () -> Void
) -> AnyView)

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
  
  func createInputViewBuilder() -> InputViewBuilder? {
    var inputViewBuilder: InputViewBuilder?
    
    if presenter.isInitialWaitConfirmState() {
      inputViewBuilder = { _, _, _, _, _, _ in
        AnyView(
          MainButtonView(
            text: presenter.stateIsCanResendInitialRequest
            ? OChatStrings.MessengerDialogScreenLocalization.Messenger.Message.sendRequest
            : OChatStrings.MessengerDialogScreenLocalization.Messenger.Message.sendRequest
            + " \(presenter.stateSecondsUntilResendInitialRequestAllowed)"
            + " \(OChatStrings.MessengerDialogScreenLocalization.Messenger.Message.seconds)",
            isEnabled: presenter.stateIsCanResendInitialRequest,
            style: .primary,
            action: {
              Task {
                await presenter.sendInitiateChatFromDialog(toxAddress: nil)
              }
              presenter.startScheduleResendInitialRequest()
            }
          )
          .padding(.horizontal, .s4)
          .padding(.top, .s4)
        )
      }
    } else if presenter.stateContactModel.status == .offline {
      inputViewBuilder = { _, _, _, _, _, _ in
        let askToComeContact = OChatStrings.MessengerDialogScreenLocalization
          .Messenger.AskToComeContact.title
        let AskToComeContactVia = OChatStrings.MessengerDialogScreenLocalization
          .Messenger.AskToComeContactVia.title
        let seconds = OChatStrings.MessengerDialogScreenLocalization
          .Messenger.Message.seconds
        
        return AnyView(
          MainButtonView(
            text: presenter.stateIsAskToComeContact ?
            askToComeContact :
              "\(AskToComeContactVia) \(presenter.stateSecondsUntilAskToComeContactAllowed) \(seconds)",
            isEnabled: presenter.stateIsAskToComeContact,
            style: .primary,
            action: {
              Task {
                await presenter.sendPushNotification()
              }
              presenter.startAskToComeContactTimer()
            }
          )
          .padding(.horizontal, .s4)
          .padding(.top, .s4)
        )
        
      }
    }
    return inputViewBuilder
  }
}

// MARK: - Private Ready To Chat

private extension MessengerDialogScreenView {
  @ViewBuilder
  func readyToChatView() -> some View {
    ChatView(
      messages: presenter.stateMessengeModels,
      placeholder: presenter.getMainPlaceholder(),
      isDownloadAvailability: presenter.stateIsDownloadAvailability,
      isSendButtonEnabled: presenter.stateMyStatus == .online,
      onChange: { newValue in
        Task {
          await presenter.setUserIsTyping(text: newValue)
        }
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
        Task {
          await presenter.saveImageToGallery(url)
        }
      },
      onVideoSave: { url in
        Task {
          await presenter.saveVideoToGallery(url)
        }
      },
      inputViewBuilder: createInputViewBuilder()
    )
    .setAvailableInput(.full)
    .showMessageTimeView(false)
    .showDateHeaders(showDateHeaders: false)
    .showMessageName(presenter.stateIsShowMessageName)
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
      Task {
        await presenter.loadMoreMessage(before: message)
      }
    }
    .mediaPickerTheme()
  }
}

// MARK: - Private Initial

private extension MessengerDialogScreenView {
  func createInitialAddressView() -> some View {
    VStack {
      ScrollView(.vertical, showsIndicators: false) {
        informationView(model: presenter.getInitialHintModel())
      }
      
      Spacer()
      
      HStack {
        ChatFieldView(
          "\(presenter.getInitialPlaceholder())",
          message: $presenter.stateContactAdress,
          maxLength: presenter.stateContactAdressMaxLength,
          onChange: nil,
          header: {
            EmptyView()
          },
          footer: {
            EmptyView()
          }
        )
        .chatFieldStyle(.capsule)
        
        CircleButtonView(
          isEnabled: !presenter.stateContactAdress.isEmpty,
          type: .send,
          size: .standart,
          style: .custom(color: SKStyleAsset.constantAzure.swiftUIColor),
          action: {
            Task {
              await presenter.sendInitiateChatFromDialog(toxAddress: presenter.stateContactAdress)
            }
          }
        )
        
      }
      .padding(.horizontal, .s4)
      .frame(minHeight: .s14)
    }
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
              Task {
                await presenter.confirmRequestForDialog()
              }
            }
          
          MainButtonView(
            text: presenter.getRequestButtonCancelTitle(),
            style: .critical) {
              Task {
                await presenter.cancelRequestForDialog()
              }
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
          bundle: .main
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
      // Создаем переменную для хранения viewController
      var viewController: UIViewController?
      
      // Используем Task для выполнения асинхронного кода
      Task {
        // Вызываем асинхронную функцию createModule и сохраняем результат
        viewController = await MessengerDialogScreenAssembly().createModule(
          contactModel: .mock(),
          contactAdress: nil,
          services: ApplicationServicesStub()
        ).viewController
      }
      
      // Возвращаем viewController, если он был создан, иначе пустой UIViewController
      return viewController ?? UIViewController()
    }
  }
}
