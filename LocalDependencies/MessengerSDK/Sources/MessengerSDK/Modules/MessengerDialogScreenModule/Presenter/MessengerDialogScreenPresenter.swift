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
  let stateShowMessengeMaxCount = 100
  
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
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  ///   - dialogModel: Моделька с данными
  ///   - contactAdress: Адрес контакта
  init(interactor: MessengerDialogScreenInteractorInput,
       factory: MessengerDialogScreenFactoryInput,
       dialogModel: ContactModel?,
       contactAdress: String?) {
    self.interactor = interactor
    self.factory = factory
    stateContactAdress = contactAdress ?? (dialogModel?.toxAddress ?? "")
    stateIsDeeplinkAdress = contactAdress != nil
    let contact = dialogModel ?? factory.createInitialContact(address: contactAdress ?? "")
    stateContactModel = contact
    
    stateMessengeModels = factory.createMessageModels(
      models: contact.messenges,
      contactModel: contact
    )
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = { [weak self] in
    guard let self else { return }
    initialSetup()
  }
  
  lazy var viewWillDisappear: (() -> Void)? = { [weak self] in
    guard let self else { return }
    moduleOutput?.messengerDialogWillDisappear()
    setUserIsTyping(text: "")
    markMessageAsRead(contactModel: stateContactModel)
  }
  
  // MARK: - Internal func
  
  func loadMoreMessage(before: Message) {
    // TODO: - Сделать пагинацию
  }
  
  func removeMessage(id: String) {
    if let messageIndex = stateMessengeModels.firstIndex(where: { $0.id == id }) {
      stateMessengeModels.remove(at: messageIndex)
    }
    
    Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { [weak self] _ in
      guard let self else { return }
      moduleOutput?.removeMessage(id: id, contact: stateContactModel)
    }
  }
  
  func retrySendMessage(messengeModel: MessengeModel) {}
  
  func saveImageToGallery(_ imageURL: URL) {
    interactor.saveImageToGallery(imageURL) { [weak self] isSuccess in
      guard let self else { return }
      if isSuccess {
        interactor.showNotification(.positive(title: "Изображение сохранено в галерее"))
      } else {
        interactor.showNotification(.negative(title: "Ошибка сохранения"))
      }
    }
    impactFeedback.impactOccurred()
  }
  
  func sendMessage(
    messenge: String,
    replyMessageText: String?
  ) {
    impactFeedback.impactOccurred()
    var updatedContactModel = stateContactModel
    
    let messengeModel = MessengeModel(
      messageType: .own,
      messageStatus: .sending,
      message: messenge,
      replyMessageText: replyMessageText,
      images: [],
      videos: [],
      recording: nil
    )
    
    updatedContactModel.messenges.append(messengeModel)
    stateContactModel = updatedContactModel
    
    stateMessengeModels = factory.createMessageModels(
      models: updatedContactModel.messenges,
      contactModel: stateContactModel
    )
    
    DispatchQueue.global().async { [weak self] in
      guard let self else { return }
      moduleOutput?.sendMessage(contact: updatedContactModel)
    }
  }
  
  @MainActor
  func sendMessage(
    messenge: String,
    medias: [Media],
    recording: ExyteChat.Recording?,
    replyMessageText: String?
  ) async {
    impactFeedback.impactOccurred()
    var updatedContactModel = stateContactModel
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
    
    updatedContactModel.messenges.append(messengeModel)
    stateContactModel = updatedContactModel
    
    stateMessengeModels = factory.createMessageModels(
      models: updatedContactModel.messenges,
      contactModel: stateContactModel
    )
    
    DispatchQueue.global().async { [weak self] in
      guard let self else { return }
      moduleOutput?.sendMessage(contact: updatedContactModel)
    }
  }
  
  func sendInitiateChatFromDialog(toxAddress: String?) {
    impactFeedback.impactOccurred()
    var updatedModel = stateContactModel
    updatedModel.toxAddress = toxAddress ?? stateContactAdress
    stateContactModel = updatedModel
    
    DispatchQueue.global().async { [weak self] in
      self?.moduleOutput?.sendInitiateChatFromDialog(contactModel: updatedModel)
    }
    
    updateCenterBarButtonView(isHidden: false)
  }
  
  func confirmRequestForDialog() {
    moduleOutput?.confirmRequestForDialog(contactModel: stateContactModel)
  }
  
  func cancelRequestForDialog() {
    moduleOutput?.cancelRequestForDialog(contactModel: stateContactModel)
    moduleOutput?.closeMessengerDialog()
  }
  
  func isInitialChatValidation() -> Bool {
    !stateContactAdress.isEmpty && stateContactAdress.count == stateContactAdressMaxLength
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
    stateContactModel.status == .initialChat && !stateContactModel.toxAddress.isNilOrEmpty || (stateContactModel.encryptionPublicKey ?? "").isEmpty
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
  
  func setUserIsTyping(text: String) {
    guard let toxPublicKey = stateContactModel.toxPublicKey else {
      return
    }
    
    DispatchQueue.global().async { [weak self] in
      self?.moduleOutput?.setUserIsTyping(!text.isEmpty, to: toxPublicKey, completion: { _ in })
    }
  }
  
  func copyToClipboard(text: String) {
    impactFeedback.impactOccurred()
    Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { [weak self] _ in
      guard let self else { return }
      interactor.copyToClipboard(text: text)
      interactor.showNotification(.neutral(title: "Текст скопирован"))
    }
  }
  
  func startAskToComeContactTimer() {
    stateIsAskToComeContact = false
    stateSecondsUntilAskToComeContactAllowed = 30
    
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
      guard let self = self else { return }
      self.updateAskToComeContactTimer()
    }
  }
  
  func sendPushNotification() {
    guard stateContactModel.pushNotificationToken != nil else {
      interactor.showNotification(.negative(title: "Контакт не включил уведомления на устройстве!"))
      return
    }
    
    var updatedContactModel = stateContactModel
    if updatedContactModel.messenges.last?.messageType != .systemSuccess {
      updatedContactModel.messenges.append(
        .init(
          messageType: .systemSuccess,
          messageStatus: .sent,
          message: "Вы уведомили вашего контакта, что вы хотите пообщаться. Ожидайте его появления в чате.",
          replyMessageText: nil,
          images: [],
          videos: [],
          recording: nil
        )
      )
    }
    
    stateContactModel = updatedContactModel
    
    DispatchQueue.global().async { [weak self] in
      guard let self else { return }
      moduleOutput?.saveContactModel(updatedContactModel)
      moduleOutput?.sendPushNotification(contact: updatedContactModel)
    }
  }
}

// MARK: - MessengerDialogScreenModuleInput

extension MessengerDialogScreenPresenter: MessengerDialogScreenModuleInput {
  func handleFileSender(progress: Int, publicToxKey: String) {
    guard stateContactModel.toxPublicKey == publicToxKey else {
      return
    }
    
    if progress == 100 {
      updateCenterBarButtonView()
      return
    }
    updateCenterBarButtonView(descriptionForSendFile: "Передача файла: \(progress)%")
  }
  
  func handleFileReceive(progress: Int, publicToxKey: String) {
    guard stateContactModel.toxPublicKey == publicToxKey else {
      return
    }
    
    if progress == 100 {
      updateCenterBarButtonView()
      return
    }
    updateCenterBarButtonView(descriptionForSendFile: "Получение файла: \(progress)%")
  }
  
  func updateDialog() {
    interactor.getNewContactModels(stateContactModel) { [weak self] contactModel in
      guard let self else { return }
      
      if isWelcomeMessageAllowed(contactModel: contactModel) {
        addWelcomeMessage(contactModel: contactModel)
        return
      }
      
      self.stateContactModel = contactModel
      
      stateMessengeModels = factory.createMessageModels(
        models: contactModel.messenges,
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
  func userSelectRetryAction(_ model: SKAbstractions.MessengeModel) {
    retrySendMessage(messengeModel: model)
  }
  
  func userSelectDeleteAction(_ model: SKAbstractions.MessengeModel) {
    removeMessage(id: model.id)
  }
  
  func userSelectCopyAction(_ model: SKAbstractions.MessengeModel) {
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
    markMessageAsRead(contactModel: stateContactModel)
    
    barButtonView = SKChatBarButtonView(
      .init(
        leftImage: nil,
        centerText: nil,
        rightImage: nil,
        isEnabled: false,
        action: {}
      )
    )
    
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
  
  func markMessageAsRead(contactModel: ContactModel) {
    guard contactModel.status != .initialChat else {
      return
    }
    var contactUpdated = contactModel
    if contactUpdated.isNewMessagesAvailable {
      contactUpdated.isNewMessagesAvailable = false
    }
    
    DispatchQueue.global().async { [weak self] in
      self?.moduleOutput?.saveContactModel(contactUpdated)
    }
  }
  
  func updateCenterBarButtonView(
    isHidden: Bool = false,
    descriptionForSendFile: String? = nil
  ) {
    var title = stateContactAdress
    if let toxAddress = stateContactModel.toxAddress, !toxAddress.isEmpty {
      title = toxAddress
    }
    
    var descriptionView = stateContactModel.isTyping ? "Печатает..." : stateContactModel.status.title
    if let descriptionForSendFile {
      descriptionView = descriptionForSendFile
    }
    
    barButtonView?.titleView.text = factory.createHeaderTitleFrom(title)
    barButtonView?.descriptionView.text = descriptionView
    
    barButtonView?.iconLeftView.isHidden = stateContactModel.isTyping
    barButtonView?.typingIndicator.isHidden = !stateContactModel.isTyping
    barButtonView?.isHidden = isHidden
    barButtonView?.iconLeftView.image = stateContactModel.status.imageStatus
  }
  
  func addWelcomeMessage(contactModel: ContactModel) {
    var contactUpdated = contactModel
    let publicKeyIsEmpty = (stateContactModel.encryptionPublicKey ?? "").isEmpty
    
    let sender = "Поздравляем! Вас успешно добавили в контакты. Теперь дождитесь, когда ваш новый контакт вам напишет"
    let receiver = "Поздравляем! Вы успешно добавили контакт. Пожалуйста, отправьте сообщение первым, чтобы начать общение"
    
    contactUpdated.messenges.append(
      .init(
        messageType: .systemSuccess,
        messageStatus: .sent,
        message: publicKeyIsEmpty ? sender : receiver,
        replyMessageText: nil,
        images: [],
        videos: [],
        recording: nil
      )
    )
    
    DispatchQueue.global().async { [weak self] in
      self?.moduleOutput?.saveContactModel(contactUpdated)
    }
  }
  
  func isWelcomeMessageAllowed(contactModel: ContactModel) -> Bool {
    let isMessengesIsEmpty = contactModel.messenges.filter({ !$0.messageType.isSystem }).isEmpty
    let isContainsSystemMessengeSuccess = contactModel.messenges.contains(where: ({
      $0.messageType == .systemSuccess
    }))
    return isMessengesIsEmpty && !isContainsSystemMessengeSuccess && contactModel.status == .online
  }
}

// MARK: - Constants

private enum Constants {}
