//
//  TorService.swift
//  SKServices
//
//  Created by Vitalii Sosin on 03.06.2024.
//

import Foundation
import Tor
import SKAbstractions

public class TorService: NSObject, URLSessionDelegate, ITorService {
  
  // MARK: - Public properties
  
  /// Singleton instance
  public static let shared = TorService()
  public var stateAction: ((_ state: TorSessionState) -> Void)?
  
  // MARK: - Private properties
  
  private var config: TorConfiguration = TorConfiguration()
  private var thread: TorThread?
  private var controller: TorController?
  private var authDirPath = ""
  private var onionAddress: String?
  
  private var sessionConfiguration: URLSessionConfiguration {
    let session = URLSessionConfiguration.default
    session.connectionProxyDictionary = [
      kCFProxyTypeKey: kCFProxyTypeSOCKS,
      kCFStreamPropertySOCKSProxyHost: "localhost",
      kCFStreamPropertySOCKSProxyPort: Constants.proxyPort
    ]
    return session
  }
  
  private lazy var session = URLSession(
    configuration: sessionConfiguration,
    delegate: self,
    delegateQueue: OperationQueue()
  )
  
  // MARK: - Init
  
  private override init() {
    super.init()
    
    setupTorControllerObservers()
    startMonitoringService()
  }
  
  // MARK: - Public func
  
  public func getOnionAddress() -> Result<String, TorServiceError> {
    if let onionAddress {
      return .success(onionAddress)
    } else {
      do {
        let onionAddressPath = try torHiddenServiceDirectoryPath().get().appending("/hostname")
        var hostname = try String(contentsOfFile: onionAddressPath, encoding: .utf8)
        hostname = removeNewlines(from: hostname)
        self.onionAddress = hostname
        return .success(hostname)
      } catch {
        return .failure(.onionAddressForTorHiddenServiceCouldNotBeLoaded)
      }
    }
  }
  
  public func getSession() -> URLSession {
    session
  }
  
  public func getPrivateKey() -> Result<String, TorServiceError> {
    let path: String
    switch torHiddenServiceDirectoryPath() {
    case let .success(result):
      path = result
    case let .failure(error):
      return .failure(error)
    }
    
    let privateKeyPath = path.appending("/private_key")
    do {
      let privateKey = try String(contentsOfFile: privateKeyPath, encoding: .utf8)
      return .success(privateKey)
    } catch {
      return(.failure(.errorLoadingPrivateKey))
    }
  }
  
  /// Метод для запуска клиента Tor
  public func start(completion: ((Result<Void, TorServiceError>) -> Void)?) {
    let port = Constants.hiddenServicePort
    if case let .failure(error) = updateTorConfiguration(port) {
      completion?(.failure(error))
      return
    }
    if case let .failure(error) = setupConfiguration(port) {
      completion?(.failure(error))
      return
    }
    if case let .failure(error) = setProperPermissions() {
      completion?(.failure(error))
      return
    }
    
    /// Запуск потока Tor
    startTorIfNeeded()
    
    Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
      guard let self else {
        return
      }
      
      if var hostname = try? String(contentsOfFile: "\(self.torHiddenServiceDirectoryPath())/hostname") {
        hostname = self.removeNewlines(from: hostname)
        self.onionAddress = hostname
      }
      
      /// Подключение контроллера Tor
      do {
        if !(self.controller?.isConnected ?? false) {
          try self.controller?.connect()
        }
        
        let cookie = try Data(
          contentsOf: config.dataDirectory!.appendingPathComponent("control_auth_cookie"),
          options: NSData.ReadingOptions(rawValue: .zero)
        )
        
        self.controller?.authenticate(with: cookie) { (success, error) in
          if let error = error {
            completion?(.failure(.somethingWentWrong(error.localizedDescription)))
            return
          }
          
          var progressObs: Any? = nil
          progressObs = self.controller?.addObserver(
            forStatusEvents: { [weak self] (
              type: String,
              severity: String,
              action: String,
              arguments: [String : String]?
            ) -> Bool in
              guard let self else {
                return false
              }
              if let arguments,
                 let progressString = arguments["PROGRESS"],
                 let progress = Int(progressString) {
                stateAction?(.connectingProgress(progress))
                if progress >= 100 {
                  self.controller?.removeObserver(progressObs)
                }
                return true
              }
              return false
            }
          )
          
          var observer: Any?
          observer = self.controller?.addObserver(forCircuitEstablished: { [weak self] established in
            guard let self else {
              return
            }
            if established {
              stateAction?(.connected)
              self.controller?.removeObserver(observer)
            }
          })
        }
      } catch {
        completion?(.failure(.somethingWentWrong(error.localizedDescription)))
        stateAction?(.stopped)
      }
      completion?(.success(()))
    }
  }
  
  /// Метод для остановки Tor
  public func stop() -> Result<Void, TorServiceError> {
    stopCurrentTorInstance()
    stateAction?(.stopped)
    return clearAuthKeys()
  }
}

// MARK: - Private

private extension TorService {
  func setupTorControllerObservers() {
    controller?.addObserver(forStatusEvents: { [weak self] (type, severity, action, arguments) -> Bool in
      guard let self = self else { return false }
      switch (type, action) {
      case ("STATUS_GENERAL", "ERR"):
        self.stateAction?(.stopped)
        return true
      case ("CIRCUIT_ESTABLISHED", _):
        self.stateAction?(.connected)
        return true
      case ("CIRCUIT_NOT_ESTABLISHED", _):
        self.stateAction?(.stopped)
        return true
      case ("ORCONN", "CLOSED"):
        self.stateAction?(.stopped)
        return true
      case ("GUARD", "DOWN"):
        self.stateAction?(.stopped)
        return true
      case ("CIRC", "LAUNCHED"), ("CIRC", "BUILT"), ("CIRC", "FAILED"), ("CIRC", "CLOSED"):
        if let id = arguments?["ID"], let status = arguments?["STATUS"] {
          stateAction?(.circuitsUpdated(status))
        }
        return true
      default:
        print("Необработанное событие: \(type) с действием \(action)")
        return true
      }
    })
  }
  
  func startMonitoringService() {
    Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
      if self?.thread == nil || !(self?.thread?.isExecuting ?? false) {
        self?.stateAction?(.stopped)
      }
    }
  }
  
  func setProperPermissions() -> Result<Void, TorServiceError> {
    let path: String
    switch torHiddenServiceDirectoryPath() {
    case let .success(result):
      path = result
    case let .failure(error):
      return .failure(error)
    }
    
    let fileManager = FileManager.default
    do {
      try fileManager.setAttributes([.posixPermissions: 0o700], ofItemAtPath: path)
      return .success(())
    } catch {
      return .failure(.failedToSetPermissions)
    }
  }
  
  /// Метод для удаления символов новой строки из строки
  func removeNewlines(from inputString: String) -> String {
    let cleanedString = inputString.replacingOccurrences(of: "\n", with: "")
    return cleanedString
  }
  
  func updateTorConfiguration(_ port: Int) -> Result<Void, TorServiceError> {
    guard let path = try? torHiddenServiceDirectoryPath().get() else {
      return .failure(.failedToWriteTorrc("Failed to get torHiddenServiceDirectoryPath"))
    }
    
    let torConfigPath = path.appending("/.torrc")
    let hiddenServiceDir = path
    
    let torConfigContent = """
      HiddenServiceDir \(hiddenServiceDir)
      HiddenServicePort \(port) localhost:\(port)
      """
    
    do {
      try torConfigContent.write(toFile: torConfigPath, atomically: true, encoding: .utf8)
      return .success(())
    } catch {
      return .failure(.failedToWriteTorrc("Failed to write torrc at \(torConfigPath): \(error)"))
    }
  }
  
  func setupConfiguration(_ port: Int) -> Result<Void, TorServiceError> {
    // Добавление V3 авторизационных ключей в ClientOnionAuthDir, если они существуют
    if case let .failure(error) = createTorHiddenServiceDirectory() {
      return .failure(error)
    }
    switch createAuthDirectory() {
    case let .success(dirPath):
      authDirPath = dirPath
    case let .failure(error):
      return .failure(error)
    }
    
    self.thread = nil
    session.configuration.urlCache = URLCache(memoryCapacity: .zero, diskCapacity: .zero, diskPath: nil)
    stateAction?(.started)
    
    self.config.options = [
      "DNSPort": "\(Constants.dnsPort)",
      "AutomapHostsOnResolve": "1",
      "SocksPort": "\(Constants.proxyPort)", // Только Onion трафик
      "AvoidDiskWrites": "1",
      "ClientOnionAuthDir": "\(self.authDirPath)",
      "LearnCircuitBuildTimeout": "1",
      "NumEntryGuards": "1", // Увеличить количество узлов
      "SafeSocks": "1",
      "LongLivedPorts": "80,443",
      "NumCPUs": "2",
      "DisableDebuggerAttachment": "1",
      "SafeLogging": "1",
      "UseEntryGuardsAsDirGuards": "1"
    ]
    
    config.cookieAuthentication = true
    
    guard let path = try? torHiddenServiceDirectoryPath().get() else {
      return .failure(.failedToWriteTorrc("Failed to get torHiddenServiceDirectoryPath"))
    }
    
    let torrcFilePath = "\(path)/.torrc"
    var torrcFile = ""
    if FileManager.default.fileExists(atPath: torrcFilePath) {
      torrcFile = (try? String(contentsOfFile: torrcFilePath)) ?? ""
    }
    
    if torrcFile.isEmpty {
      let torrcFileContent = """
          HiddenServiceDir \(path)
          HiddenServicePort 80 \(Constants.hiddenService):\(port)
          """
      
      do {
        try torrcFileContent.write(toFile: torrcFilePath, atomically: true, encoding: .utf8)
      } catch {
        return .failure(.failedToWriteTorrc("Failed to write torrc at \(torrcFilePath): \(error)"))
      }
    }
    
    config.dataDirectory = URL(fileURLWithPath: path)
    config.arguments = ["-f", torrcFilePath]
    config.controlSocket = self.config.dataDirectory?.appendingPathComponent("cp")
    thread = TorThread(configuration: config)
    
    // Инициализация контроллера
    if self.controller == nil, let socketURL = config.controlSocket {
      self.controller = TorController(socketURL: socketURL)
    }
    return .success(())
  }
}

// MARK: - ClientOnionAuthDirectory

private extension TorService {
  /// Метод для создания директории авторизации
  func createAuthDirectory() -> Result<String, TorServiceError> {
    var path = ""
    switch torHiddenServiceDirectoryPath() {
    case let .success(result):
      path = result
    case let .failure(error):
      return .failure(error)
    }
    
    let authPath = URL(
      fileURLWithPath: path,
      isDirectory: true
    ).appendingPathComponent(
      "onion_auth",
      isDirectory: true
    ).path
    
    do {
      try FileManager.default.createDirectory(
        atPath: authPath,
        withIntermediateDirectories: true,
        attributes: [FileAttributeKey.posixPermissions: 0o700]
      )
      return .success(authPath)
    } catch {
      return .failure(.authDirectoryPreviouslyCreated)
    }
  }
  
  /// Удаляет все ключи авторизации и возвращает результат операции.
  func clearAuthKeys() -> Result<Void, TorServiceError> {
    let fileManager = FileManager.default
    do {
      let filePaths = try fileManager.contentsOfDirectory(atPath: authDirPath)
      for filePath in filePaths {
        let url = URL(fileURLWithPath: authDirPath + "/" + filePath)
        try fileManager.removeItem(at: url)
      }
      return .success(())
    } catch {
      return .failure(.errorWhenDeletingKeys(error.localizedDescription))
    }
  }
}


// MARK: - HiddenServiceDirectory

private extension TorService {
  /// Метод для создания директории для Tor
  func createTorHiddenServiceDirectory() -> Result<Void, TorServiceError> {
    var path = ""
    switch torHiddenServiceDirectoryPath() {
    case let .success(result):
      path = result
    case let .failure(error):
      return .failure(error)
    }
    
    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: path) {
      do {
        try fileManager.createDirectory(
          atPath: path,
          withIntermediateDirectories: true,
          attributes: [FileAttributeKey.posixPermissions: 0o700]
        )
        return .success(())
      } catch {
        return .failure(.failedToCreateDirectory("Failed to create directory at \(path): \(error)"))
      }
    } else {
      return .success(())
    }
  }
  
  /// Метод для получения пути к директории Tor
  func torHiddenServiceDirectoryPath() -> Result<String, TorServiceError> {
#if targetEnvironment(simulator)
    torHiddenServiceDirectoryPathSimulator()
#else
    torHiddenServiceDirectoryPathDevice()
#endif
  }
  
  /// Метод для получения пути к директории Tor
  func torHiddenServiceDirectoryPathSimulator() -> Result<String, TorServiceError> {
    // Используем tmp директорию для хранения данных Tor, чтобы сократить путь
    let torDirPath = "/tmp/tor"
    
    // Проверяем существует ли директория и создаём если необходимо
    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: torDirPath) {
      do {
        try fileManager.createDirectory(atPath: torDirPath, withIntermediateDirectories: true, attributes: nil)
        return .success((torDirPath))
      } catch {
        return .failure(.failedToCreateDirectory("Failed to create tor directory at \(torDirPath): \(error)"))
      }
    }
    return .success(torDirPath)
  }
  
  func torHiddenServiceDirectoryPathDevice() -> Result<String, TorServiceError> {
    // Получаем путь к кэш-директории
    guard let cacheDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
      return .failure(.unableToAccessTheCachesDirectory)
    }
    
    // Строим путь к директории tor, используя полученный путь к кэш-директории
    let torDirPath = cacheDir.appending("/tor")
    
    // Проверяем существует ли директория и создаём если необходимо
    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: torDirPath) {
      do {
        try fileManager.createDirectory(atPath: torDirPath, withIntermediateDirectories: true, attributes: nil)
        return .success(torDirPath)
      } catch {
        return .failure(.failedToCreateDirectory("Failed to create tor directory at \(torDirPath): \(error)"))
      }
    } else {
      return .success(torDirPath)
    }
  }
  
  func startTorIfNeeded() {
    if thread == nil {
      thread = TorThread(configuration: config)
    }
    
    if thread?.isExecuting == false {
      thread?.start()
    }
  }
  
  func stopCurrentTorInstance() {
    if let thread = thread, thread.isExecuting {
      thread.cancel()
      while thread.isExecuting {
        // Добавим небольшую задержку, чтобы избежать блокировки потока
        RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.1))
      }
      self.thread = nil
      print("Tor thread stopped.")
    } else {
      print("No Tor thread to stop.")
    }
    controller?.disconnect()
    controller = nil
  }
}

// MARK: - Constants

private enum Constants {
  static var proxyPort: Int {
#if targetEnvironment(simulator)
    return 9052
#else
    return 9050
#endif
  }
  
  static var dnsPort: Int {
#if targetEnvironment(simulator)
    return 12347
#else
    return 12345
#endif
  }
  
  static var hiddenServicePort: Int {
    80
  }
  
  static var hiddenService: String {
    "127.0.0.1"
  }
}
