//
//  MessengerDialogScreenPresenter.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions
import SKFoundation
import ExyteChat
import ExyteMediaPicker

final class MessengerDialogScreenPresenter: ObservableObject {
  
  // MARK: - View state
  
  // MARK: - Initial chat state
  
  @Published var stateContactAdress = ""
  @Published var stateIsDeeplinkAdress = false
  @Published var stateContactAdressMaxLength = 76
  @Published var stateShowInitialTips = true
  @Published var stateIsSendInitialRequestButton = false
  
  @Published var stateIsCanResendInitialRequest = false
  @Published var stateSecondsUntilResendInitialRequestAllowed = 0
  
  // MARK: - Offline contact
  
  @Published var stateIsAskToComeContact = true
  @Published var stateSecondsUntilAskToComeContactAllowed = 0
  
  // MARK: - Chat state
  
  @Published var stateContactModel: ContactModel
  @Published var stateMessengeModels: [Message] = []
  @Published var stateInputMessengeText = ""
  @Published var stateInputMessengeTextMaxLength = 1_000
  @Published var stateShowMessengeMaxCount = 100
  
  @Published var stateIsDownloadAvailability = false
  @Published var stateIsChatHistoryStored = false
  @Published var stateIsShowMessageName = false
  @Published var stateMyStatus: AppSettingsModel.Status = .offline
  
  // MARK: - Internal properties
  
  weak var moduleOutput: MessengerDialogScreenModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: MessengerDialogScreenInteractorInput
  private let factory: MessengerDialogScreenFactoryInput
  private weak var deleteRightBarButton: SKBarButtonItem?
  private var barButtonView: SKChatBarButtonView?
  private var resendInitialRequestTimer: Timer?
  private var timer: Timer?
  private let impactFeedback = UIImpactFeedbackGenerator(style: .soft)
  private var toxSelfAddress = ""
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  ///   - contactModel: Моделька контакта
  ///   - contactAdress: Адрес контакта
  @MainActor
  init(interactor: MessengerDialogScreenInteractorInput,
       factory: MessengerDialogScreenFactoryInput,
       contactModel: ContactModel?,
       contactAdress: String?) async {
    self.interactor = interactor
    self.factory = factory
    stateContactAdress = contactAdress ?? (contactModel?.toxAddress ?? "")
    stateIsDeeplinkAdress = contactAdress != nil
    let contact = contactModel ?? factory.createInitialContact(address: contactAdress ?? "")
    stateContactModel = contact
    stateIsDownloadAvailability = contact.canSaveMedia
    stateIsChatHistoryStored = contact.isChatHistoryStored
    
    let listMessengeModels = await interactor.getListMessengeModels(stateContactModel)
    self.stateMessengeModels = factory.createMessageModels(
      models: listMessengeModels,
      contactModel: stateContactModel
    )
    
    if contactModel == nil {
      let messengeModel: MessengeModel = .init(
        messageType: .systemSuccess,
        messageStatus: .sent,
        message: OChatStrings.MessengerDialogScreenLocalization.Messenger
          .Initial.note,
        replyMessageText: nil,
        images: [],
        videos: [],
        recording: nil
      )
      
      await interactor.addMessenge(
        contact.id,
        messengeModel
      )
    }
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = { [weak self] in
    guard let self else { return }
    initialSetup()
  }
  
  lazy var viewWillDisappear: (() -> Void)? = { [weak self] in
    Task { [weak self] in
      guard let self else { return }
      await moduleOutput?.messengerDialogWillDisappear()
      await setUserIsTyping(text: "")
      await markMessageAsRead(contactModel: stateContactModel)
    }
  }
  
  // MARK: - Internal func
  
  func loadMoreMessage(before: Message) async {
    // TODO: - Сделать пагинацию
  }
  
  func removeMessage(id: String) async {
    await MainActor.run { [weak self] in
      guard let self else { return }
      if let messageIndex = stateMessengeModels.firstIndex(where: { $0.id == id }) {
        stateMessengeModels.remove(at: messageIndex)
      }
    }
    
    await moduleOutput?.removeMessage(id: id, contact: stateContactModel)
  }
  
  func retrySendMessage(messengeModel: MessengeModel) async {
    await sendMessage(
      messenge: messengeModel.message,
      replyMessageText: messengeModel.replyMessageText
    )
  }
  
  func saveImageToGallery(_ imageURL: URL) async {
    guard stateContactModel.canSaveMedia else {
      return
    }
    
    interactor.saveImageToGallery(imageURL) { [weak self] isSuccess in
      guard let self else { return }
      if isSuccess {
        interactor.showNotification(
          .positive(
            title: OChatStrings.MessengerDialogScreenLocalization.Messenger.ImageSavedToGallery.title
          )
        )
      } else {
        interactor.showNotification(
          .negative(
            title: OChatStrings.MessengerDialogScreenLocalization.Messenger
              .SavingError.title
          )
        )
      }
    }
  }
  
  func saveVideoToGallery(_ imageURL: URL) async {
    guard stateContactModel.canSaveMedia else {
      return
    }
    
    interactor.saveVideoToGallery(imageURL) { [weak self] isSuccess in
      guard let self else { return }
      if isSuccess {
        interactor.showNotification(
          .positive(
            title: OChatStrings.MessengerDialogScreenLocalization.Messenger
              .VideoSavedToGallery.title
          )
        )
      } else {
        interactor.showNotification(
          .negative(
            title: OChatStrings.MessengerDialogScreenLocalization.Messenger
              .SavingError.title
          )
        )
      }
    }
    await impactFeedback.impactOccurred()
  }
  
  func sendMessage(
    messenge: String,
    replyMessageText: String?
  ) async {
    await impactFeedback.impactOccurred()
    let updatedContactModel = stateContactModel
    
    let messengeModel = MessengeModel(
      messageType: .own,
      messageStatus: .sending,
      message: messenge,
      replyMessageText: replyMessageText,
      images: [],
      videos: [],
      recording: nil
    )
    
    await interactor.addMessenge(updatedContactModel.id, messengeModel)
    let listMessengeModels = await interactor.getListMessengeModels(updatedContactModel)
    
    await MainActor.run { [weak self, updatedContactModel] in
      guard let self else { return }
      stateContactModel = updatedContactModel
      stateMessengeModels = factory.createMessageModels(
        models: listMessengeModels,
        contactModel: stateContactModel
      )
    }
    await moduleOutput?.sendMessage(contact: updatedContactModel)
  }
  
  func sendMessage(
    messenge: String,
    medias: [Media],
    recording: ExyteChat.Recording?,
    replyMessageText: String?
  ) async {
    await impactFeedback.impactOccurred()
    var recordingModel: MessengeRecordingModel?
    
    if let recording,
       let recordingTempURL = recording.url,
       let recordingURL = interactor.saveObjectWith(tempURL: recordingTempURL),
       let recordingName = interactor.getFileName(from: recordingURL) {
      recordingModel = .init(
        duration: recording.duration,
        waveformSamples: recording.waveformSamples,
        name: recordingName
      )
    }
    
    let imageTasks = medias.filter { $0.type == .image }.map { media in
      Task { () -> MessengeImageModel? in
        guard let thumbnailTempURL = await media.getThumbnailURL(),
              let thumbnailURL = interactor.saveObjectWith(tempURL: thumbnailTempURL),
              let fullTempURL = await media.getURL(),
              let fullURL = interactor.saveObjectWith(tempURL: fullTempURL),
              let thumbnailName = interactor.getFileName(from: thumbnailURL),
              let fullName = interactor.getFileName(from: fullURL) else {
          return nil
        }
        
        return MessengeImageModel(
          id: UUID().uuidString,
          thumbnailName: thumbnailName,
          fullName: fullName
        )
      }
    }
    
    let videoTasks = medias.filter { $0.type == .video }.map { media in
      Task { () -> MessengeVideoModel? in
        guard let thumbnailTempURL = await media.getThumbnailURL(),
              let thumbnailURL = interactor.saveObjectWith(tempURL: thumbnailTempURL),
              let fullTempURL = await media.getURL(),
              let fullURL = interactor.saveObjectWith(tempURL: fullTempURL),
              let thumbnailName = interactor.getFileName(from: thumbnailURL),
              let fullName = interactor.getFileName(from: fullURL) else {
          return nil
        }
        
        return MessengeVideoModel(
          id: UUID().uuidString,
          thumbnailName: thumbnailName,
          fullName: fullName
        )
      }
    }
    
    let videos = await withTaskGroup(of: MessengeVideoModel?.self) { group -> [MessengeVideoModel] in
      for task in videoTasks {
        group.addTask { await task.value }
      }
      
      var results = [MessengeVideoModel]()
      for await result in group {
        if let videoModel = result {
          results.append(videoModel)
        }
      }
      return results
    }
    
    let images = await withTaskGroup(of: MessengeImageModel?.self) { group -> [MessengeImageModel] in
      for task in imageTasks {
        group.addTask { await task.value }
      }
      
      var results = [MessengeImageModel]()
      for await result in group {
        if let videoModel = result {
          results.append(videoModel)
        }
      }
      return results
    }
    
    let messengeModel = MessengeModel(
      messageType: .own,
      messageStatus: .sending,
      message: messenge,
      replyMessageText: replyMessageText,
      images: images,
      videos: videos,
      recording: recordingModel
    )
    
    await interactor.addMessenge(stateContactModel.id, messengeModel)
    let listMessengeModels = await interactor.getListMessengeModels(stateContactModel)
    
    await MainActor.run { [weak self, stateContactModel] in
      guard let self else { return }
      stateMessengeModels = factory.createMessageModels(
        models: listMessengeModels,
        contactModel: stateContactModel
      )
    }
    
    await moduleOutput?.sendMessage(contact: stateContactModel)
  }
  
  func sendInitiateChatFromDialog(toxAddress: String?) async {
    await impactFeedback.impactOccurred()
    let isToxSelfAddressValid = toxSelfAddress != stateContactAdress
    let isAdressMaxLengthValid = stateContactAdress.count == stateContactAdressMaxLength
    
    guard isToxSelfAddressValid else {
      interactor.showNotification(
        .negative(
          title: OChatStrings.MessengerDialogScreenLocalization
            .Notification.SelfAddressError.title
        )
      )
      return
    }
    guard isAdressMaxLengthValid else {
      interactor.showNotification(
        .negative(
          title: OChatStrings.MessengerDialogScreenLocalization
            .Notification.ContactAddressValidationError.title
        )
      )
      return
    }
    
    startScheduleResendInitialRequest()
    
    var updatedModel = stateContactModel
    updatedModel.toxAddress = toxAddress ?? stateContactAdress
    
    await MainActor.run { [weak self, updatedModel] in
      guard let self else { return }
      stateContactModel = updatedModel
    }
    
    await moduleOutput?.sendInitiateChatFromDialog(contactModel: updatedModel)
    updateCenterBarButtonView(isHidden: false)
  }
  
  func confirmRequestForDialog() async {
    await moduleOutput?.confirmRequestForDialog(contactModel: stateContactModel)
  }
  
  func cancelRequestForDialog() async {
    await moduleOutput?.cancelRequestForDialog(contactModel: stateContactModel)
    await moduleOutput?.closeMessengerDialog()
  }
  
  func isChatValidation() -> Bool {
    !stateInputMessengeText.isEmpty && stateContactModel.status == .online
  }
  
  func getInitialPlaceholder() -> String {
    factory.createInitialPlaceholder()
  }
  
  func getMainPlaceholder() -> String {
    factory.createMainPlaceholder()
  }
  
  func getInitialHintModel() -> MessengerDialogHintModel {
    factory.createInitialHintModel()
  }
  
  func getRequestHintModel() -> MessengerDialogHintModel {
    factory.createRequestHintModel()
  }
  
  func getRequestButtonCancelTitle() -> String {
    factory.createRequestButtonCancelTitle()
  }
  
  func isInitialAddressEntryState() -> Bool {
    stateContactModel.status == .initialChat &&
    (stateContactModel.toxAddress.isNilOrEmpty || stateIsDeeplinkAdress)
  }
  
  func isInitialWaitConfirmState() -> Bool {
    stateContactModel.status == .initialChat && 
    !stateContactModel.toxAddress.isNilOrEmpty ||
    (stateContactModel.encryptionPublicKey ?? "").isEmpty
  }
  
  func isRequestChatState() -> Bool {
    stateContactModel.status == .requestChat
  }
  
  func startScheduleResendInitialRequest() {
    // Устанавливаем начальное состояние
    stateIsCanResendInitialRequest = false
    stateSecondsUntilResendInitialRequestAllowed = 60
    
    // Инвалидируем предыдущий таймер, если он существует
    resendInitialRequestTimer?.invalidate()
    
    // Запускаем новый таймер, который обновляется каждую секунду
    resendInitialRequestTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
      guard let self = self else { return }
      
      // Уменьшаем количество оставшихся секунд
      self.stateSecondsUntilResendInitialRequestAllowed -= 1
      
      // Если отсчёт завершён, обновляем состояние и останавливаем таймер
      if self.stateSecondsUntilResendInitialRequestAllowed <= 0 {
        self.stateIsCanResendInitialRequest = true
        timer.invalidate()
      }
    }
  }
  
  func setUserIsTyping(text: String) async {
    guard let toxPublicKey = stateContactModel.toxPublicKey,
          let getAppSettingsModel = await moduleOutput?.getAppSettingsModel(),
          getAppSettingsModel.isTypingIndicatorEnabled else {
      return
    }
    
    await moduleOutput?.setUserIsTyping(!text.isEmpty, to: toxPublicKey)
  }
  
  func copyToClipboard(text: String) {
    impactFeedback.impactOccurred()
    Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { [weak self] _ in
      guard let self else { return }
      let textCopiedTitle = OChatStrings.MessengerDialogScreenLocalization.Messenger
        .TextCopied.title
      
      interactor.copyToClipboard(text: text)
      interactor.showNotification(
        .positive(
          title: textCopiedTitle
        )
      )
    }
  }
  
  func startAskToComeContactTimer() {
    stateIsAskToComeContact = false
    stateSecondsUntilAskToComeContactAllowed = 30
    
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
      guard let self = self else { return }
      self.updateAskToComeContactTimer()
    }
  }
  
  func sendPushNotification() async {
    guard stateContactModel.pushNotificationToken != nil else {
      let contactDidNotEnableNotificationsTitle = OChatStrings.MessengerDialogScreenLocalization.Messenger
        .ContactDidNotEnableNotifications.title
      
      interactor.showNotification(
        .negative(
          title: "\(contactDidNotEnableNotificationsTitle)!"
        )
      )
      return
    }
    
    let youNotifiedContactTitle = OChatStrings.MessengerDialogScreenLocalization.Message
      .YouNotifiedContact.title
    
    await interactor.addMessenge(
      stateContactModel.id,
      .init(
        messageType: .systemSuccess,
        messageStatus: .sent,
        message: youNotifiedContactTitle,
        replyMessageText: nil,
        images: [],
        videos: [],
        recording: nil
      )
    )
    let listMessengeModels = await interactor.getListMessengeModels(stateContactModel)
    
    await MainActor.run { [weak self] in
      guard let self else { return }
      stateMessengeModels = factory.createMessageModels(
        models: listMessengeModels,
        contactModel: stateContactModel
      )
    }
    await moduleOutput?.sendPushNotification(contact: stateContactModel)
  }
}

// MARK: - MessengerDialogScreenModuleInput

extension MessengerDialogScreenPresenter: MessengerDialogScreenModuleInput {
  @MainActor
  func updateMyStatus(_ status: SKAbstractions.AppSettingsModel.Status) async {
    guard stateMyStatus != status else { return }
    stateMyStatus = status
  }
  
  func handleFileSender(progress: Int, publicToxKey: String) {
    guard stateContactModel.toxPublicKey == publicToxKey else {
      return
    }
    
    if progress == 100 {
      updateCenterBarButtonView()
      return
    }
    
    let fileTransferTitle = OChatStrings.MessengerDialogScreenLocalization.Messenger
      .FileTransfer.title
    
    updateCenterBarButtonView(descriptionForSendFile: "\(fileTransferTitle): \(progress)%")
  }
  
  func handleFileReceive(progress: Int, publicToxKey: String) {
    guard stateContactModel.toxPublicKey == publicToxKey else {
      return
    }
    
    if progress == 100 {
      updateCenterBarButtonView()
      return
    }
    let receivingFileTitle = OChatStrings.MessengerDialogScreenLocalization.Messenger
      .ReceivingFile.title
    updateCenterBarButtonView(descriptionForSendFile: "\(receivingFileTitle): \(progress)%")
  }
  
  func updateDialog() {
    Task { @MainActor [weak self] in
      guard let self else { return }
      let contactModel = await interactor.getNewContactModels(stateContactModel)
      self.stateContactModel = contactModel
      stateIsDownloadAvailability = contactModel.canSaveMedia
      stateIsChatHistoryStored = contactModel.isChatHistoryStored
      
      let listMessengeModels = await interactor.getListMessengeModels(stateContactModel)
      stateMessengeModels = factory.createMessageModels(
        models: listMessengeModels,
        contactModel: stateContactModel
      )
      updateCenterBarButtonView(isHidden: false)
    }
  }
}

// MARK: - MessengerDialogScreenInteractorOutput

extension MessengerDialogScreenPresenter: MessengerDialogScreenInteractorOutput {}

// MARK: - MessengerDialogScreenFactoryOutput

extension MessengerDialogScreenPresenter: MessengerDialogScreenFactoryOutput {
  @MainActor
  func userSelectRetryAction(_ model: SKAbstractions.MessengeModel) async {
    await retrySendMessage(messengeModel: model)
  }
  
  @MainActor
  func userSelectDeleteAction(_ model: SKAbstractions.MessengeModel) async {
    await removeMessage(id: model.id)
  }
  
  @MainActor
  func userSelectCopyAction(_ model: SKAbstractions.MessengeModel) async {
    copyToClipboard(text: model.message)
  }
}

// MARK: - SceneViewModel

extension MessengerDialogScreenPresenter: SceneViewModel {
  var centerBarButtonItem: SKBarButtonViewType? {
    .customView(view: barButtonView)
  }
}

// MARK: - Private

private extension MessengerDialogScreenPresenter {
  func initialSetup() {
    barButtonView = SKChatBarButtonView(
      .init(
        leftImage: nil,
        centerText: nil,
        rightImage: nil,
        isEnabled: false,
        action: {}
      )
    )
    
    Task { @MainActor [weak self] in
      guard let self,
            let getAppSettingsModel = await moduleOutput?.getAppSettingsModel() else {
        return
      }
      await markMessageAsRead(contactModel: stateContactModel)
      toxSelfAddress = await interactor.getToxAddress() ?? ""
      
      let listMessenge = await interactor.getListMessengeModels(stateContactModel)
      stateMessengeModels = factory.createMessageModels(
        models: listMessenge,
        contactModel: stateContactModel
      )
    }
    
    updateCenterBarButtonView(isHidden: isInitialAddressEntryState() || isRequestChatState())
    if isInitialWaitConfirmState() {
      startScheduleResendInitialRequest()
    }
  }
  
  func updateAskToComeContactTimer() {
    stateSecondsUntilAskToComeContactAllowed -= 1
    
    if stateSecondsUntilAskToComeContactAllowed <= 0 {
      // Останавливаем таймер
      timer?.invalidate()
      timer = nil
      
      stateIsAskToComeContact = true
    }
  }
  
  func markMessageAsRead(contactModel: ContactModel) async {
    guard contactModel.status != .initialChat else {
      return
    }
    var contactUpdated = contactModel
    if contactUpdated.isNewMessagesAvailable {
      contactUpdated.isNewMessagesAvailable = false
    }
    
    await moduleOutput?.saveContactModel(contactUpdated)
  }
  
  func updateCenterBarButtonView(
    isHidden: Bool = false,
    descriptionForSendFile: String? = nil
  ) {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      var title = stateContactAdress
      if let toxAddress = stateContactModel.toxAddress, !toxAddress.isEmpty {
        title = toxAddress
      }
      
      let typingTitle = OChatStrings.MessengerDialogScreenLocalization.Messenger
        .Typing.title
      
      var descriptionView = stateContactModel.isTyping ? "\(typingTitle)..." : stateContactModel.status.title
      if let descriptionForSendFile {
        descriptionView = descriptionForSendFile
      }
      
      barButtonView?.titleView.text = factory.createHeaderTitleFrom(title)
      barButtonView?.descriptionView.text = descriptionView
      barButtonView?.isHidden = isHidden
      barButtonView?.iconLeftView.image = stateContactModel.status.imageStatus
    }
  }
}

// MARK: - Constants

private enum Constants {}
