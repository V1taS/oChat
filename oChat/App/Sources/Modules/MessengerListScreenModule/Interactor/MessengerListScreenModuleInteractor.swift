//
//  MessengerListScreenModuleInteractor.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI
import SKAbstractions
import SKStyle
import AVFoundation
import SKManagers

final class MessengerListScreenModuleInteractor {
  
  // MARK: - Internal properties
  
  weak var output: MessengerListScreenModuleInteractorOutput?
  
  // MARK: - Private properties
  
  private let cryptoManager: ICryptoManager
  private let contactManager: IContactManager
  private let notificationManager: INotificationManager
  private let fileManager: ISKFileManager
  private let messageManager: IMessageManager
  private let settingsManager: ISettingsManager
  private let toxManager: IToxManager
  private let interfaceManager: IInterfaceManager
  
  private let systemService: ISystemService
  private let deepLinkService: IDeepLinkService
  private let notificationService: INotificationService
  private let modelHandlerService: IMessengerModelHandlerService
  
  // MARK: - Initialization
  
  init(
    services: IApplicationServices,
    cryptoManager: ICryptoManager,
    contactManager: IContactManager,
    notificationManager: INotificationManager,
    fileManager: ISKFileManager,
    messageManager: IMessageManager,
    settingsManager: ISettingsManager,
    toxManager: IToxManager,
    interfaceManager: IInterfaceManager
  ) {
    self.cryptoManager = cryptoManager
    self.contactManager = contactManager
    self.notificationManager = notificationManager
    self.fileManager = fileManager
    self.messageManager = messageManager
    self.settingsManager = settingsManager
    self.toxManager = toxManager
    self.interfaceManager = interfaceManager
    
    self.systemService = services.userInterfaceAndExperienceService.systemService
    self.deepLinkService = services.userInterfaceAndExperienceService.deepLinkService
    self.notificationService = services.userInterfaceAndExperienceService.notificationService
    self.modelHandlerService = services.messengerService.modelHandlerService
  }
}

// MARK: - MessengerListScreenModuleInteractorInput

extension MessengerListScreenModuleInteractor: MessengerListScreenModuleInteractorInput {
  
  // MARK: - CryptoManager
  
  func decrypt(_ encryptedText: String?) async -> String? {
    await cryptoManager.decrypt(encryptedText)
  }
  
  func encrypt(_ text: String?, publicKey: String) -> String? {
    cryptoManager.encrypt(text, publicKey: publicKey)
  }
  
  func decrypt(_ encryptedData: Data?) async -> Data? {
    await cryptoManager.decrypt(encryptedData)
  }
  
  func encrypt(_ data: Data?, publicKey: String) -> Data? {
    cryptoManager.encrypt(data, publicKey: publicKey)
  }
  
  func publicKey(from privateKey: String) -> String? {
    cryptoManager.publicKey(from: privateKey)
  }
  
  // MARK: - ToxManager
  
  func getToxPublicKey(from address: String) -> String? {
    toxManager.getToxPublicKey(from: address)
  }
  
  func getToxAddress() async -> String? {
    await toxManager.getToxAddress()
  }
  
  func getToxPublicKey() async -> String? {
    await toxManager.getToxPublicKey()
  }
  
  func confirmFriendRequest(with publicToxKey: String) async -> String? {
    await toxManager.confirmFriendRequest(with: publicToxKey)
  }
  
  func setSelfStatus(isOnline: Bool) async {
    await toxManager.setSelfStatus(isOnline: isOnline)
  }
  
  func setUserIsTyping(_ isTyping: Bool, to toxPublicKey: String) async -> Result<Void, Error> {
    await toxManager.setUserIsTyping(isTyping, to: toxPublicKey)
  }
  
  func startPeriodicFriendStatusCheck(completion: (() -> Void)?) async {
    await toxManager.startPeriodicFriendStatusCheck(completion: completion)
  }
  
  func stratTOXService() async {
    await toxManager.startToxService()
  }
  
  // MARK: - ContactManager
  
  func getContactModels() async -> [ContactModel] {
    await contactManager.getContactModels()
  }
  
  func saveContactModel(_ model: ContactModel) async {
    await contactManager.saveContactModel(model)
  }
  
  func removeContactModels(_ contactModel: ContactModel) async -> Bool {
    await contactManager.removeContactModel(contactModel)
  }
  
  func getContactModelsFrom(toxAddress: String) async -> ContactModel? {
    await contactManager.getContactModelFrom(toxAddress: toxAddress)
  }
  
  func getContactModelsFrom(toxPublicKey: String) async -> ContactModel? {
    await contactManager.getContactModelFrom(toxPublicKey: toxPublicKey)
  }
  
  func setStatus(_ model: ContactModel, _ status: ContactModel.Status) async {
    await contactManager.setStatus(model, status)
  }
  
  func setAllContactsIsOffline() async {
    await contactManager.setAllContactsOffline()
  }
  
  func setAllContactsNoTyping() async {
    await contactManager.setAllContactsNotTyping()
  }
  
  func clearAllMessengeTempID() async {
    await contactManager.clearAllMessengeTempID()
  }
  
  // MARK: - SettingsManager
  
  func getAppSettingsModel() async -> AppSettingsModel {
    await settingsManager.getAppSettingsModel()
  }
  
  func passcodeNotSetInSystemIOSheck() async {
    await settingsManager.passcodeNotSetInSystemIOSCheck(
      errorMessage: OChatStrings.MessengerListScreenModuleLocalization
        .State.Notification.PasscodeNotSet.title
    )
  }
  
  // MARK: - NotificationManager
  
  func sendPushNotification(contact: ContactModel) async {
    await notificationManager.sendPushNotification(contact: contact)
  }
  
  func requestNotification() async -> Bool {
    await notificationManager.requestNotification()
  }
  
  func isNotificationsEnabled() async -> Bool {
    await notificationManager.isNotificationsEnabled()
  }
  
  func saveMyPushNotificationToken(_ token: String) async {
    await notificationManager.saveMyPushNotificationToken(token)
  }
  
  func getPushNotificationToken() async -> String? {
    await notificationManager.getPushNotificationToken()
  }
  
  // MARK: - FileManager
  func getFileNameWithoutExtension(from url: URL) -> String {
    fileManager.getFileNameWithoutExtension(from: url)
  }
  
  func getFileName(from url: URL) -> String? {
    fileManager.getFileName(from: url)
  }
  
  func saveObjectToCachesWith(fileName: String, fileExtension: String, data: Data) -> URL? {
    fileManager.saveObjectToCachesWith(
      fileName: fileName,
      fileExtension: fileExtension,
      data: data
    )
  }
  
  func saveObjectWith(fileName: String, fileExtension: String, data: Data) -> URL? {
    fileManager.saveObjectWith(fileName: fileName, fileExtension: fileExtension, data: data)
  }
  
  func readObjectWith(fileURL: URL) -> Data? {
    fileManager.readObjectWith(fileURL: fileURL)
  }
  
  func clearTemporaryDirectory() {
    fileManager.clearTemporaryDirectory()
  }
  
  func saveObjectWith(tempURL: URL) -> URL? {
    fileManager.saveObjectWith(tempURL: tempURL)
  }
  
  func getFirstFrame(from url: URL) -> Data? {
    fileManager.getFirstFrame(from: url)
  }
  
  func resizeThumbnailImageWithFrame(data: Data) -> Data? {
    fileManager.resizeThumbnailImageWithFrame(data: data)
  }
  
  func receiveAndUnzipFile(
    zipFileURL: URL,
    password: String
  ) async throws -> (
    model: MessengerNetworkRequestModel,
    recordingDTO: MessengeRecordingDTO?,
    files: [URL]
  ) {
    try await fileManager.receiveAndUnzipFile(zipFileURL: zipFileURL, password: password)
  }
  
  // MARK: - MessageManager
  
  func sendMessage(
    toxPublicKey: String,
    messengerRequest: MessengerNetworkRequestModel?
  ) async -> Int32? {
    await messageManager.sendMessage(
      toxPublicKey: toxPublicKey,
      messengerRequest: messengerRequest
    )
  }
  
  func initialChat(
    senderAddress: String,
    messengerRequest: MessengerNetworkRequestModel?
  ) async -> Int32? {
    await messageManager.initialChat(
      senderAddress: senderAddress,
      messengerRequest: messengerRequest
    )
  }
  
  func sendFile(
    toxPublicKey: String,
    recipientPublicKey: String,
    recordModel: MessengeRecordingModel?,
    messengerRequest: MessengerNetworkRequestModel,
    files: [URL]
  ) async {
    await messageManager.sendFile(
      toxPublicKey: toxPublicKey,
      recipientPublicKey: recipientPublicKey,
      recordModel: recordModel,
      messengerRequest: messengerRequest,
      files: files
    )
  }
  
  // MARK: - InterfaceManager
  
  func setRedDotToTabBar(value: String?) {
    interfaceManager.setRedDotToTabBar(value: value)
  }
  
  // MARK: - SystemService
  
  func getDeviceIdentifier() -> String {
    systemService.getDeviceIdentifier()
  }
  
  // MARK: - DeepLinkService
  
  func getDeepLinkAdress() async -> String? {
    await deepLinkService.getMessengerAddress()
  }
  
  func deleteDeepLinkURL() {
    deepLinkService.deleteDeepLinkURL()
  }
  
  // MARK: - NotificationService (Directly accessed)
  
  func showNotification(_ type: NotificationServiceType) {
    notificationService.showNotification(type)
  }
  
  // MARK: - ModelHandlerService (Directly accessed)
  
  func getMessengerModel() async -> MessengerModel {
    await modelHandlerService.getMessengerModel()
  }
}

// MARK: - Private

private extension MessengerListScreenModuleInteractor {}

// MARK: - Constants

private enum Constants {}
