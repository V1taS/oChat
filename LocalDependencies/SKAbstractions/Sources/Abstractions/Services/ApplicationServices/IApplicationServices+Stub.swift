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
                                            IAnalyticsService, IMessengerService,
                                            ISecureDataManagerService, ICryptoService, ICloudKitService,
                                            IModelHandlerService, IAppSettingsManager,
                                            IModelSettingsManager, IDataManagementService,
                                            IAccessAndSecurityManagementService, IUserInterfaceAndExperienceService,
                                            IMessagesService {
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
  public func getMessengerService(privateKey: String) -> any IMessengerService { self }
  public func getSecureDataManagerService(_ serviceName: SecureDataManagerServiceKey) -> any ISecureDataManagerService { self }
  public func getCryptoService() -> any ICryptoService { self }
  public func getCloudKitService() -> any ICloudKitService { self }
  public func getModelHandlerService() -> IModelHandlerService { self }
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
  public var modelHandlerService: any IModelHandlerService { self }
  public var appSettingsManager: any IAppSettingsManager { self }
  public var modelSettingsManager: any IModelSettingsManager { self }
  public var uiService: any IUIService { self }
  public var systemService: any ISystemService { self }
  public var notificationService: any INotificationService { self }
  public var messengerService: any IMessengerService { self }
  public func messagesService(privateKey: String) -> any IMessagesService { self }
  
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
  public func getoChatModel(completion: @escaping (oChatModel) -> Void) {}
  public func saveoChatModel(_ model: oChatModel, completion: (() -> Void)?) {}
  public func getAppSettingsModel(completion: @escaping (AppSettingsModel) -> Void) {}
  public func saveAppSettingsModel(_ model: AppSettingsModel, completion: (() -> Void)?) {}
  public func getWalletModels(completion: @escaping ([WalletModel]) -> Void) {}
  public func saveWalletModels(_ models: [WalletModel], completion: (() -> Void)?) {}
  public func setIsEnabledFaceID(_ value: Bool, completion: (() -> Void)?) {}
  public func setAppPassword(_ value: String?, completion: (() -> Void)?) {}
  public func setCurrentCurrency(_ value: CurrencyModel, completion: (() -> Void)?) {}
  public func setIsEnabledNotifications(_ value: Bool, completion: (() -> Void)?) {}
  public func createWallet12Words() -> String? { nil }
  public func createWallet24Words() -> String? { nil }
  public func recoverMnemonic(_ mnemonic: String) -> String? { nil }
  public func isValidMnemonic(_ input: String) -> Bool { false }
  public func isValidPrivateKey(_ input: String) -> Bool { false }
  public func getWalletDetails(mnemonic: String) -> (publicKey: String, privateKey: String)? { nil }
  public func saveWalletModel(_ model: WalletModel, completion: (() -> Void)?) {}
  public func sha512(from input: String) -> String { "" }
  public func sha512(from inputData: Data) -> String { "" }
  public func sha256(from input: String) -> String { "" }
  public func sha256(from inputData: Data) -> String { "" }
  public func hideTextBase64(_ textBase64: String?, withImage image: Data, completionBlock: @escaping EncoderCompletionBlock) {}
  public func getTextBase64From(image: Data, completionBlock: @escaping DecoderCompletionBlock) {}
  public func checkIfPasscodeIsSet(completion: ((Result<Void, SystemServiceError>) -> Void)?) {}
  public func setIsPrimaryWallet(_ model: WalletModel, _ value: Bool, completion: (() -> Void)?) {}
  public func getModelSettingsManager() -> any IModelSettingsManager { self }
  public func setNameWallet(_ model: WalletModel, _ name: String, completion: (() -> Void)?) {}
  public func setNameWallet(_ model: WalletModel, _ name: String, completion: ((WalletModel?) -> Void)?) {}
  public func deleteWallet(_ model: WalletModel, completion: (() -> Void)?) {}
  public func getPricesForTokens(tokens: [TokenModel], currency: CurrencyModel, completion: ((Result<[TokenModel], NetworkError>) -> Void)?) {}
  public func searchTokensByNameOrSymbol(chain: TokenNetworkType?, text: String, limit: Int, completion: ((Result<[TokenModel], NetworkError>) -> Void)?) {}
}
