//
//  IApplicationServices+Stub.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 31.05.2024.
//

import SwiftUI

// MARK: - ServicesStub

public final class ApplicationServicesStub: IApplicationServices, IDataManagerService, IDataMappingService,
                                            INotificationService, IPermissionService, ISessionService,
                                            ISteganographyService, ISystemService, IUIService,
                                            IAnalyticsService, ISecureDataManagerService, ICryptoService,
                                            ICloudKitService, IAppSettingsManager, IDataManagementService,
                                            IAccessAndSecurityManagementService, IUserInterfaceAndExperienceService,
                                            IDeepLinkService, IPushNotificationService, IZipArchiveService {
  public func checkIfPasscodeIsSet() async -> Result<Void, SystemServiceError> { .success(()) }
  public func setAccessType(_ accessType: AppSettingsModel.AccessType) async {}
  public func setFakeAppPassword(_ value: String?) async {}
  public func setIsFakeAccessEnabled(_ value: Bool) async {}
  public func setIsPremiumEnabled(_ value: Bool) async {}
  public func setIsTypingIndicatorEnabled(_ value: Bool) async {}
  public func setCanSaveMedia(_ value: Bool) async {}
  public func setIsChatHistoryStored(_ value: Bool) async {}
  public func setIsVoiceChangerEnabled(_ value: Bool) async {}
  public func setIsEnabledFaceID(_ value: Bool) async {}
  public func setAppPassword(_ value: String?) async {}
  public func setIsEnabledNotifications(_ value: Bool) async {}
  public func setIsNewMessagesAvailable(_ value: Bool, toxAddress: String) async {}
  public func encodeModel<T>(_ model: T) async throws -> Data? where T : Encodable { nil }
  public func decodeModel<T>(_ type: T.Type, from data: Data) async throws -> T? where T : Decodable { nil }
  public func requestNotification() async -> Bool { false}
  public func isNotificationsEnabled() async -> Bool { false }
  public func requestCamera() async -> Bool { false }
  public func requestGallery() async -> Bool { false }
  public func requestFaceID() async -> Bool { false }
  public func openSettings() async -> Result<Void, SystemServiceError> { .success(()) }
  public func saveImageToGallery(_ imageData: Data?) async -> Bool { false }
  public func saveVideoToGallery(_ video: URL?) async -> Bool { false }
  public func getConfigurationValue<T>(from keyName: String) async throws -> T? { nil }
  public func saveDeepLinkURL(_ url: URL) async { }
  public func getMessengerAddress() async -> String? { nil }
  public func isFirstLaunch() -> Bool { false }
  public func saveVideoToGallery(_ video: URL?, completion: ((Bool) -> Void)?) {}
  public func getFileNameWithoutExtension(from url: URL) -> String { "" }
  public func getFileName(from url: URL) -> String? { nil }
  public func constructFileURL(fileName: String, fileExtension: String?) -> URL? { nil }
  public func saveObjectToCachesWith(fileName: String, fileExtension: String, data: Data) -> URL? { nil }
  public func clearTemporaryDirectory() {}
  public func saveObjectWith(tempURL: URL) -> URL? {  nil }
  public func zipFiles(atPaths paths: [URL], toDestination destinationPath: URL, password: String?, progress: ((Double) -> ())?) throws {}
  public func unzipFile(atPath path: URL, toDestination destinationPath: URL, overwrite: Bool, password: String?, progress: ((Double) -> ())?, fileOutputHandler: ((URL) -> Void)?) throws {}
  public var zipArchiveService: any IZipArchiveService { self }
  public func decrypt(_ data: Data?, privateKey: String) -> Data? { nil }
  public func encrypt(_ data: Data?, publicKey: String) -> Data? { nil }
  public func setIsNewMessagesAvailable(_ value: Bool, toxAddress: String, completion: (() -> Void)?) {}
  public func sendPushNotification(title: String, body: String, customData: [String : Any], deviceToken: String) {}
  public var pushNotificationService: any IPushNotificationService { self }
  public func setAllContactsIsOffline(completion: (() -> Void)?) {}
  public func saveDeepLinkURL(_ url: URL, completion: (() -> Void)?) {}
  public func deleteDeepLinkURL() {}
  public func getMessengerAdress(completion: ((String?) -> Void)?) {}
  public var deepLinkService: any IDeepLinkService { self }
  public func generateQRCode(from string: String, backgroundColor: Color, foregroundColor: Color, iconIntoQR: UIImage?, iconSize: CGSize, iconBackgroundColor: Color?, completion: ((UIImage?) -> Void)?) {}
  public var messengerService: any IMessengerService { MessengerServiceStub() }
  public func deleteAllData() -> Bool { false }
  public init() {}
  public func getDataManagerService() -> any IDataManagerService { self }
  public func getDataMappingService() -> any IDataMappingService { self }
  public func getNotificationService() -> any INotificationService { self }
  public func getPermissionService() -> any IPermissionService { self }
  public lazy var sessionService: any ISessionService = self
  public func getSteganographyService() -> any ISteganographyService { self }
  public func getSystemService() -> any ISystemService { self }
  public func getUIService() -> any IUIService { self }
  public func getAnalyticsService() -> any IAnalyticsService { self }
  public func getSecureDataManagerService(_ serviceName: SecureDataManagerServiceKey) -> any ISecureDataManagerService { self }
  public func getCryptoService() -> any ICryptoService { self }
  public func getCloudKitService() -> any ICloudKitService { self }
  public func getAppSettingsManager() -> IAppSettingsManager { self }
  public func getDataManagementService() -> any IDataManagementService { self }
  public func getAccessAndSecurityManagementService() -> any IAccessAndSecurityManagementService { self }
  public func getUserInterfaceAndExperienceService() -> any IUserInterfaceAndExperienceService { self }
  public var dataManagementService: any IDataManagementService { self }
  public var accessAndSecurityManagementService: any IAccessAndSecurityManagementService { self }
  public var userInterfaceAndExperienceService: any IUserInterfaceAndExperienceService { self }
  public var analyticsService: any IAnalyticsService { self }
  public var cloudKitService: any ICloudKitService { self }
  public var permissionService: any IPermissionService { self }
  public var steganographyService: any ISteganographyService { self }
  public var cryptoService: any ICryptoService { self }
  public var dataManagerService: any IDataManagerService { self }
  public var dataMappingService: any IDataMappingService { self }
  public var appSettingsManager: any IAppSettingsManager { self }
  public var uiService: any IUIService { self }
  public var systemService: any ISystemService { self }
  public var notificationService: any INotificationService { self }
  public func messagesEncryptionService(privateKey: String) -> any IMessagesService { MessengerServiceStub() }
  
  public func loadFromKeychain(completion: @escaping (Result<Data, any Error>) -> Void) {}
  public func saveToKeychain(_ data: Data, completion: @escaping (Result<Void, any Error>) -> Void) {}
  public func removeFromKeychain(completion: @escaping (Result<Void, any Error>) -> Void) {}
  public func encodeModel<T>(_ model: T, completion: @escaping (Result<Data, any Error>) -> Void) where T : Encodable {}
  public func decodeModel<T>(_ type: T.Type, from data: Data, completion: @escaping (Result<T, any Error>) -> Void) where T : Decodable {}
  public func showNotification(_ type: NotificationServiceType, action: (() -> Void)?) {}
  public func showNotification(_ type: NotificationServiceType) {}
  public func requestNotification(completion: @escaping (Bool) -> Void) {}
  public func isNotificationsEnabled(completion: @escaping (Bool) -> Void) {}
  public func requestCamera(completion: @escaping (Bool) -> Void) {}
  public func requestGallery(completion: @escaping (Bool) -> Void) {}
  public func requestFaceID(completion: @escaping (Bool) -> Void) {}
  public func startSession() {}
  public func endSession() {}
  public func isSessionActive() -> Bool { false }
  public func updateLastActivityTime() {}
  public func countPixelsInImage(imageData: Data, completion: @escaping (Result<Int, SteganographyServiceProcessingError>) -> Void) {}
  public func hideTextIntoImage(imageData: Data, inputText: String, completion: @escaping (Result<Data, SteganographyServiceProcessingError>) -> Void) {}
  public func getTextFromImage(imageData: Data, completion: @escaping (Result<String, SteganographyServiceProcessingError>) -> Void) {}
  public func openSettings(completion: @escaping (Result<Void, SystemServiceError>) -> Void) {}
  public func openSettings() {}
  public func saveColorScheme(_ interfaceStyle: UIUserInterfaceStyle?) {}
  public func getColorScheme() -> UIUserInterfaceStyle? { nil }
  public func saveImageToGallery(_ imageData: Data?, completion: ((Bool) -> Void)?) {}
  public func copyToClipboard(text: String, completion: @escaping (Result<Void, SystemServiceError>) -> Void) {}
  public func copyToClipboard(text: String) {}
  public func generateQRCode(from string: String, iconIntoQR: UIImage?, completion: ((UIImage?) -> Void)?) {}
  public func generateQRCode(from string: String, backgroundColor: Color, foregroundColor: Color, iconIntoQR: UIImage?, iconSize: CGSize, completion: ((UIImage?) -> Void)?) {}
  public func saveObjectWith(fileName: String, fileExtension: String, data: Data) -> URL? { nil }
  public func readObjectWith(fileURL: URL) -> Data? { nil }
  public func deleteObjectWith(fileURL: URL, isRemoved: ((Bool) -> Void)?) {}
  public func openURLInSafari(urlString: String, completion: @escaping (Result<Void, SystemServiceError>) -> Void) {}
  public func openURLInSafari(urlString: String) {}
  public func getCurrentLanguage() -> AppLanguageType { .russian }
  public func trackEvent(_ event: String, parameters: [String : Any]) {}
  public func log(_ message: String) {}
  public func error(_ error: String, file: String, function: String, line: Int) {}
  public func error(_ error: any Error, file: String, function: String, line: Int) {}
  public func getAllLogs() -> URL? { nil }
  public func getErrorLogs() -> URL? { nil }
  public func clearAllLogs() {}
  public func getDeviceModel() -> String { "" }
  public func getSystemName() -> String { "" }
  public func getSystemVersion() -> String { "" }
  public func getDeviceIdentifier() -> String { "" }
  public func getAppVersion() -> String { "" }
  public func getAppBuildNumber() -> String { "" }
  public func publicKey(from privateKey: String) throws -> String { "" }
  public func encrypt(_ message: String, publicKey: String) throws -> String { "" }
  public func decrypt(_ message: String, privateKey: String) throws -> String { "" }
  public func getKeyExchangeType() -> MessengerKeyExchangeType { .encryption }
  public func setTheirPublicKey(_ key: String?) {}
  public func prepareMessage(_ message: String?) -> String? { nil }
  public func handleReceiveMessages(_ message: String?) -> (theirPublicKey: String?, message: String?) { (nil, nil)}
  public func string(for key: String) -> String? { nil }
  public func data(for key: String) -> Data? { nil }
  public func deleteData(for key: String) -> Bool { false }
  public func save(string: String, key: String) -> Bool { false }
  public func save(data: Data, key: String) -> Bool { false }
  public func model<T>(for key: String) -> T? where T : Decodable { nil }
  public func publicKey(from privateKey: String) -> String? { nil }
  public func encrypt(_ data: String?, publicKey: String) -> String? { nil }
  public func decrypt(_ encryptedData: String?, privateKey: String) -> String? { nil }
  public var sessionDidExpireAction: (() -> Void)?
  public func getString(for key: String) -> String? { nil }
  public func getData(for key: String) -> Data? { nil }
  public func getModel<T>(for key: String) -> T? where T : Decodable { nil }
  public func saveString(_ string: String, key: String) -> Bool { false }
  public func saveData(_ data: Data, key: String) -> Bool { false }
  public func saveModel<T>(_ model: T, for key: String) -> Bool where T : Encodable { false}
  public func sessionDidExpire() {}
  public func getConfigurationValue<T>(from keyName: String, completion: @escaping (T?) -> Void) {}
  public func getImage(for url: URL?, completion: @escaping (UIImage?) -> Void) {}
  public func getAppSettingsModel(completion: @escaping (AppSettingsModel) -> Void) {}
  public func saveAppSettingsModel(_ model: AppSettingsModel, completion: (() -> Void)?) {}
  public func setIsEnabledFaceID(_ value: Bool, completion: (() -> Void)?) {}
  public func setAppPassword(_ value: String?, completion: (() -> Void)?) {}
  public func setIsEnabledNotifications(_ value: Bool, completion: (() -> Void)?) {}
  public func createWallet12Words() -> String? { nil }
  public func createWallet24Words() -> String? { nil }
  public func recoverMnemonic(_ mnemonic: String) -> String? { nil }
  public func isValidMnemonic(_ input: String) -> Bool { false }
  public func isValidPrivateKey(_ input: String) -> Bool { false }
  public func getWalletDetails(mnemonic: String) -> (publicKey: String, privateKey: String)? { nil }
  public func sha512(from input: String) -> String { "" }
  public func sha512(from inputData: Data) -> String { "" }
  public func sha256(from input: String) -> String { "" }
  public func sha256(from inputData: Data) -> String { "" }
  public func hideTextBase64(_ textBase64: String?, withImage image: Data, completionBlock: @escaping EncoderCompletionBlock) {}
  public func getTextBase64From(image: Data, completionBlock: @escaping DecoderCompletionBlock) {}
  public func checkIfPasscodeIsSet(completion: ((Result<Void, SystemServiceError>) -> Void)?) {}
  public var serverStateAction: ((TorServerState) -> Void)?
  public var sessionStateAction: ((TorSessionState) -> Void)?
  public var stateErrorServiceAction: ((Result<Void, TorServiceError>) -> Void)?
  public func getOnionAddress() -> Result<String, TorServiceError> { .success("") }
  public func getPrivateKey() -> Result<String, TorServiceError> { .success("") }
  public func start(completion: ((Result<Void, TorServiceError>) -> Void)?) { }
  public func stop() -> Result<Void, TorServiceError> { .success(()) }
  public func sendMessage(_ message: String, peerAddress: String, completion: ((Result<Void, any Error>) -> Void)?) {}
  public func getOnionAddress(completion: ((Result<String, TorServiceError>) -> Void)?) {}
  public func getPrivateKey(completion: ((Result<String, TorServiceError>) -> Void)?) {}
  public func stop(completion: ((Result<Void, TorServiceError>) -> Void)?) {}
}

// MARK: - MessengerServiceStub

public final class MessengerServiceStub: IMessengerModelSettingsManager, IMessengerModelHandlerService,
                                         IMessagesService, IMessengerService, IP2PChatManager, IAppSettingsManager {
  public func clearAllMessenge() async {}
  public func setAccessType(_ accessType: AppSettingsModel.AccessType) async {}
  public func setFakeAppPassword(_ value: String?) async {}
  public func setIsFakeAccessEnabled(_ value: Bool) async {}
  public func setIsPremiumEnabled(_ value: Bool) async {}
  public func setIsTypingIndicatorEnabled(_ value: Bool) async {}
  public func setCanSaveMedia(_ value: Bool) async {}
  public func setIsChatHistoryStored(_ value: Bool) async {}
  public func setIsVoiceChangerEnabled(_ value: Bool) async {}
  public func setToxStateAsString(_ toxStateAsString: String?) async {}
  public func setStatus(_ model: ContactModel, _ status: ContactModel.Status) async {}
  public func setNameContact(_ model: ContactModel, _ name: String) async -> ContactModel? { nil }
  public func setToxAddress(_ model: ContactModel, _ address: String) async -> ContactModel? { nil }
  public func clearAllMessengeTempID() async {}
  public func setMeshAddress(_ model: ContactModel, _ meshAddress: String) async -> ContactModel? { nil }
  public func addMessenge(_ model: ContactModel, _ messengeModel: MessengeModel) async -> ContactModel? { nil }
  public func setEncryptionPublicKey(_ model: ContactModel, _ publicKey: String) async -> ContactModel? { nil }
  public func saveMyPushNotificationToken(_ token: String) async {}
  public func deleteContact(_ model: ContactModel) async {}
  public func setAllContactsIsOffline() async {}
  public func setAllContactsNoTyping() async {}
  public func getMessengerModel() async -> MessengerModel { .setDefaultValues() }
  public func getAppSettingsModel() async -> AppSettingsModel { .setDefaultValues() }
  public func saveAppSettingsModel(_ model: AppSettingsModel) async {}
  public func getContactModels() async -> [ContactModel] { [] }
  public func saveContactModel(_ model: ContactModel) async {}
  public func saveContactModels(_ models: [ContactModel]) async {}
  public func removeContactModels(_ contactModel: ContactModel) async {}
  public func setIsEnabledFaceID(_ value: Bool) async {}
  public func setAppPassword(_ value: String?) async {}
  public func setIsEnabledNotifications(_ value: Bool) async {}
  public func setIsNewMessagesAvailable(_ value: Bool, toxAddress: String) async {}
  public func start(saveDataString: String?) async throws {}
  public func getToxAddress() async -> String? { nil }
  public func getToxPublicKey() async -> String? { nil }
  public func addFriend(address: String, message: String) async -> Int32? { nil }
  public func deleteFriend(toxPublicKey: String) async -> Bool { false }
  public func friendNumber(publicToxKey: String) async -> Int32? { nil }
  public func friendConnectionStatus(toxPublicKey: String) async -> ConnectionToxStatus? { nil }
  public func confirmFriendRequest(with publicToxKey: String) async -> String? { nil }
  public func sendMessage(to toxPublicKey: String, message: String, messageType: ToxSendMessageType) async throws -> Int32? { nil }
  public func setUserIsTyping(_ isTyping: Bool, to toxPublicKey: String) async -> Result<Void, any Error> { .success(()) }
  public func startPeriodicFriendStatusCheck(completion: @escaping ([String : Bool]) -> Void) async { }
  public func sendFile(toxPublicKey: String, recipientPublicKey: String, model: MessengerNetworkRequestDTO, recordModel: MessengeRecordingModel?, files: [URL]) {}
  public func sendFile(toxPublicKey: String, model: MessengerNetworkRequestDTO, recordModel: MessengeRecordingModel?, files: [URL]) {}
  public func sendFile(toxPublicKey: String, model: MessengerNetworkRequestDTO, files: [URL]) {}
  public func setToxAddress(_ model: ContactModel, _ address: String, completion: ((ContactModel?) -> Void)?) {}
  public func clearAllMessengeTempID(completion: (() -> Void)?) {}
  public func startPeriodicFriendStatusCheck(completion: (([String : Bool]) -> Void)?) {}
  public func friendStatus(completion: @escaping (Bool) -> Void) {}
  public func setIsNewMessagesAvailable(_ value: Bool, toxAddress: String, completion: (() -> Void)?) {}
  public func saveMyPushNotificationToken(_ token: String, completion: (() -> Void)?) {}
  public func setAllContactsNoTyping(completion: (() -> Void)?) {}
  public func setSelfStatus(isOnline: Bool) {}
  public func setUserIsTyping(_ isTyping: Bool, to toxPublicKey: String, completion: @escaping (Result<Void, any Error>) -> Void) {}
  public func setAllContactsIsOffline(completion: (() -> Void)?) { }
  public func getToxPublicKey(from address: String) -> String? { nil }
  public func confirmFriendRequest(with publicKey: String, completion: @escaping (Result<String, any Error>) -> Void) {}
  public func deleteFriend(toxPublicKey: String, completion: ((Bool) -> Void)?) {}
  public func friendConnectionStatus(toxPublicKey: String, completion: ((ConnectionToxStatus?) -> Void)?) {}
  public func sendMessage(to toxPublicKey: String, message: String, messageType: ToxSendMessageType, completion: @escaping (Result<Int32, any Error>) -> Void) {}
  
  public func addFriendWithoutRequest(publicToxKey: String, completion: ((Int32?) -> Void)?) {}
  
  public func friendNumber(publicToxKey publicKey: String, completion: ((Int32?) -> Void)?) {}
  public func friendConnectionStatus(friendNumber: Int32, completion: ((ConnectionToxStatus?) -> Void)?) {}
  
  public func deleteFriend(friendNumber: Int32, completion: ((Bool) -> Void)?) {}
  
  public func addFriend(publicToxKey address: String, completion: ((Int32?) -> Void)?) {}
  
  public func getToxPublicKey(completion: @escaping (String?) -> Void) {}
  
  public func toxStateAsString(completion: ((String?) -> Void)?) {}
  
  public func addFriend(address: String, message: String, completion: ((Int32?) -> Void)?) {}
  
  public func confirmFriendRequest(with publicKey: String, completion: @escaping (Result<Int32, any Error>) -> Void) {}
  
  public func sendMessage(to friendNumber: Int32, message: String, messageType: ToxSendMessageType, completion: @escaping (Result<Int32, any Error>) -> Void) {}
  
  public func setToxStateAsString(_ toxStateAsString: String?, completion: (() -> Void)?) {}
  
  public func toxStateAsString() -> String? { nil }
  
  public func getToxAddress(completion: @escaping (Result<String, any Error>) -> Void) {}
  
  public func start(saveDataString: String?, completion: ((Result<Void, any Error>) -> Void)?) {}
  
  public func sendMessage(onionAddress: String, messengerRequest: MessengerNetworkRequestModel?, completion: @escaping (Result<Void, any Error>) -> Void) {}
  
  public func initiateChat(onionAddress: String, messengerRequest: MessengerNetworkRequestModel?, completion: @escaping (Result<Void, any Error>) -> Void) {}
  public func checkServerAvailability(onionAddress: String, completion: @escaping (Bool) -> Void) {}
  public func setStatus(_ model: ContactModel, _ status: ContactModel.Status, completion: (() -> Void)?) {}
  public func removeContactModels(_ contactModel: ContactModel, completion: (() -> Void)?) {}
  public func sendChatRequest(peerAddress: String, completion: ((Result<Void, any Error>) -> Void)?) {}
  public func setIsEnabledFaceID(_ value: Bool, completion: (() -> Void)?) {}
  public func setAppPassword(_ value: String?, completion: (() -> Void)?) {}
  public func setIsEnabledNotifications(_ value: Bool, completion: (() -> Void)?) {}
  
  public var appSettingsManager: any IAppSettingsManager { self }
  public var serverStateAction: ((TorServerState) -> Void)?
  public var sessionStateAction: ((TorSessionState) -> Void)?
  public func getOnionAddress(completion: ((Result<String, TorServiceError>) -> Void)?) {}
  public func getPrivateKey(completion: ((Result<String, TorServiceError>) -> Void)?) {}
  public func start(completion: ((Result<Void, TorServiceError>) -> Void)?) {}
  public func stop(completion: ((Result<Void, TorServiceError>) -> Void)?) {}
  public func sendMessage(_ message: String, peerAddress: String, completion: ((Result<Void, any Error>) -> Void)?) {}
  public var p2pChatManager: any IP2PChatManager { self }
  
  public func messagesEncryptionService(privateKey: String) -> any IMessagesService { self }
  public var modelSettingsManager: any IMessengerModelSettingsManager { self }
  public var modelHandlerService: any IMessengerModelHandlerService { self}
  
  public func deleteAllData() -> Bool { false }
  public func getAppSettingsModel(completion: @escaping (AppSettingsModel) -> Void) {}
  public func saveAppSettingsModel(_ model: AppSettingsModel, completion: (() -> Void)?) {}
  public func getKeyExchangeType() -> MessengerKeyExchangeType { .encryption }
  public func setTheirPublicKey(_ key: String?) {}
  public func prepareMessage(_ message: String?) -> String? { nil }
  public func handleReceiveMessages(_ message: String?) -> (theirPublicKey: String?, message: String?) { (nil, nil)}
  public func setIsOnline(_ model: ContactModel, _ value: Bool, completion: (() -> Void)?) {}
  public func setNameContact(_ model: ContactModel, _ name: String, completion: ((ContactModel?) -> Void)?) {}
  public func setOnionAddress(_ model: ContactModel, _ address: String, completion: ((ContactModel?) -> Void)?) {}
  public func setMeshAddress(_ model: ContactModel, _ meshAddress: String, completion: ((ContactModel?) -> Void)?) {}
  public func addMessenge(_ model: ContactModel, _ messengeModel: MessengeModel, completion: ((ContactModel?) -> Void)?) {}
  public func setEncryptionPublicKey(_ model: ContactModel, _ publicKey: String, completion: ((ContactModel?) -> Void)?) {}
  public func deleteContact(_ model: ContactModel, completion: (() -> Void)?) {}
  public func getMessengerModel(completion: @escaping (MessengerModel) -> Void) {}
  public func saveMessengerModel(_ model: MessengerModel, completion: (() -> Void)?) {}
  public func getContactModels(completion: @escaping ([ContactModel]) -> Void) {}
  public func saveContactModel(_ model: ContactModel, completion: (() -> Void)?) {}
  public func saveContactModels(_ models: [ContactModel], completion: (() -> Void)?) {}
}
