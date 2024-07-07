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
      return AnyView(informationView(model: presenter.getInitialHintModel()))
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
  
  func createChatFieldView(isInitialState: Bool) -> some View {
    let isValidate = isInitialState ? presenter.isInitialChatValidation() : presenter.isChatValidation()
    
    return HStack(spacing: .s4) {
      ChatFieldView(
        isInitialState ? "\(presenter.getInitialPlaceholder())" : "\(presenter.getMainPlaceholder())",
        message: isInitialState ? $presenter.stateContactAdress : $presenter.stateInputMessengeText,
        maxLength: isInitialState ? presenter.stateContactAdressMaxLength : presenter.stateInputMessengeTextMaxLength,
        onChange: { newvalue in
          presenter.setUserIsTyping(text: newvalue)
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
          presenter.sendInitiateChatFromDialog(toxAddress: nil)
          presenter.startScheduleResendInitialRequest()
        }
      }) {
        Image(systemName: "arrow.up.circle.fill")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(height: .s7)
          .foregroundColor(isValidate ? SKStyleAsset.constantAzure.swiftUIColor : SKStyleAsset.constantSlate.swiftUIColor)
          .opacity(isValidate ? 1 : 0.5)
      }
      .disabled(!isValidate)
    }
    .padding(.s4)
  }
  
  func getStyleForTips(messengeModel: MessengeModel) -> TipsView.Style {
    let style: TipsView.Style
    switch messengeModel.messageType {
    case .systemSuccess:
      return .success
    case .systemAttention:
      return .attention
    case .systemDanger:
      return .danger
    default:
      return .success
    }
  }
}

// MARK: - Private Ready To Chat

private extension MessengerDialogScreenView {
  @ViewBuilder
  func readyToChatView() -> some View {
    if presenter.isInitialWaitConfirmState() {
      ChatView(
        messages: presenter.stateMessengeModels,
        didSendMessage: { _ in },
        inputViewBuilder: { _, _, _, _, _, _ in
          MainButtonView(
            text: presenter.stateIsCanResendInitialRequest ?
            "Отправить запрос" :
              "Отправить запрос через \(presenter.stateSecondsUntilResendInitialRequestAllowed) сек.",
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
    } else if presenter.stateContactModel.status == .offline {
      ChatView(
        messages: presenter.stateMessengeModels,
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
    } else {
      ChatView(messages: presenter.stateMessengeModels) { draft in
        Task {
          let images = await draft.makeImages()
          let videos = await draft.makeVideos()
          presenter.sendMessage(messenge: draft.text, images: images, videos: videos)
        }
      }
      .setAvailableInput(.full)
      .showMessageTimeView(true)
      .showDateHeaders(showDateHeaders: true)
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

// TODO: - Вынести этот код

extension DraftMessage {
  func makeImages() async -> [MessengeImageModel] {
    await medias
      .filter { $0.type == .image }
      .asyncMap { (media : Media) -> (Media, URL?, URL?) in
        (media, await media.getThumbnailURL(), await media.getURL())
      }
      .filter { (media: Media, thumb: URL?, full: URL?) -> Bool in
        thumb != nil && full != nil
      }
      .map { media, thumb, full in
        MessengeImageModel(id: media.id.uuidString, thumbnail: thumb!, full: full!)
      }
  }
  
  func makeVideos() async -> [MessengeVideoModel] {
    await medias
      .filter { $0.type == .video }
      .asyncMap { (media : Media) -> (Media, URL?, URL?) in
        (media, await media.getThumbnailURL(), await media.getURL())
      }
      .filter { (media: Media, thumb: URL?, full: URL?) -> Bool in
        thumb != nil && full != nil
      }
      .map { media, thumb, full in
        MessengeVideoModel(id: media.id.uuidString, thumbnail: thumb!, full: full!)
      }
  }
}

extension Sequence {
  func asyncMap<T>(
    _ transform: (Element) async throws -> T
  ) async rethrows -> [T] {
    var values = [T]()
    
    for element in self {
      try await values.append(transform(element))
    }
    
    return values
  }
}
