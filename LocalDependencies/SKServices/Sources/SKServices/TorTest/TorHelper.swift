import Foundation
import Tor

@available(iOS 13.0, macOS 13, *)
public class TorHelper: NSObject, URLSessionDelegate {
  
  // MARK: - Public properties
  
  public var stateAction: ((_ state: TorState) -> Void)?
  public var cert: Data?
  
  // MARK: - Private properties
  
  private var config: TorConfiguration = TorConfiguration()
  private var thread: TorThread?
  private var controller: TorController?
  private var authDirPath = ""
  private var isRefreshing = false
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
  
  lazy var session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: OperationQueue())
  
  // MARK: - Public func
  
  public func getOnionAddress() -> String? {
    onionAddress
  }
  
  public func getPrivateKey() -> String? {
    let privateKeyPath = torHiddenServiceDirectoryPath().appending("/private_key")
    do {
      let privateKey = try String(contentsOfFile: privateKeyPath, encoding: .utf8)
      print("🟢 Private Key: \(privateKey)")
      return privateKey
    } catch {
      print("❌ Error loading private key: \(error)")
      return nil
    }
  }
  
  /// Метод для запуска клиента Tor
  func start(hiddenServicePort: Int? = nil, completion: ((Result<Void, Error>) -> Void)?) {
    let port = hiddenServicePort ?? Constants.hiddenServicePort
    updateTorConfiguration(port)
    setupConfiguration(port)
    setProperPermissions()
    
    /// Запуск потока Tor
    thread?.start()
    
    Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
      guard let self else {
        return
      }
      
      do {
        var hostname = try String(contentsOfFile: "\(self.torHiddenServiceDirectoryPath())/hostname")
        hostname = self.removeNewlines(from: hostname)
        self.onionAddress = hostname
        print("✅ SwiftTor: Tor Hidden Service on Port \(port) Onion Address for Hidden Service: \(hostname)")
      } catch {
        print("❌ SwiftTor: Onion Address for Tor Hidden Service couldn't be loaded \(error.localizedDescription)")
      }
      
      // Подключение контроллера Tor
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
            print("❌ error = \(error.localizedDescription)")
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
        stateAction?(.stopped)
      }
      completion?(.success(()))
    }
  }
  
  // Метод для остановки Tor
  public func resign() {
    controller?.disconnect()
    controller = nil
    thread?.cancel()
    thread = nil
    clearAuthKeys()
    stateAction?(.stopped)
  }
}

// MARK: - Private

@available(iOS 13.0, *)
private extension TorHelper {
  func setProperPermissions() {
    let path = torHiddenServiceDirectoryPath()
    let fileManager = FileManager.default
    do {
      try fileManager.setAttributes([.posixPermissions: 0o700], ofItemAtPath: path)
      print("Permissions set to 700 for \(path)")
    } catch {
      print("Failed to set permissions for \(path): \(error)")
    }
  }
  
  /// Метод для удаления символов новой строки из строки
  func removeNewlines(from inputString: String) -> String {
    let cleanedString = inputString.replacingOccurrences(of: "\n", with: "")
    return cleanedString
  }
  
  func updateTorConfiguration(_ port: Int) {
    let torConfigPath = torHiddenServiceDirectoryPath().appending("/.torrc")
    let hiddenServiceDir = torHiddenServiceDirectoryPath()
    
    let torConfigContent = """
      HiddenServiceDir \(hiddenServiceDir)
      HiddenServicePort \(port) localhost:\(port)
      """
    
    do {
      try torConfigContent.write(toFile: torConfigPath, atomically: true, encoding: .utf8)
      print("✅ Updated torrc with path: \(torConfigPath)")
    } catch {
      print("❌ Failed to write torrc at \(torConfigPath): \(error)")
    }
  }
  
  func setupConfiguration(_ port: Int) {
    // Добавление V3 авторизационных ключей в ClientOnionAuthDir, если они существуют
    createTorHiddenServiceDirectory()
    authDirPath = createAuthDirectory()
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
      "NumEntryGuards": "8",
      "SafeSocks": "1",
      "LongLivedPorts": "80,443",
      "NumCPUs": "2",
      "DisableDebuggerAttachment": "1",
      "SafeLogging": "1"
    ]
    
    config.cookieAuthentication = true
    
    var torrcFile = ""
    if let torrcFileTemp = try? String(contentsOfFile: "\(self.torHiddenServiceDirectoryPath())/.torrc") {
      torrcFile = torrcFileTemp
    } else {
      let torrcFileTemp = """
      HiddenServiceDir \(torHiddenServiceDirectoryPath())
      HiddenServicePort 80 \(Constants.hiddenService):\(port)
      """
      FileManager.default.createFile(
        atPath: "\(torHiddenServiceDirectoryPath())/.torrc",
        contents: torrcFile.data(
          using: .utf8
        ),
        attributes: [FileAttributeKey.posixPermissions: 0o700]
      )
      torrcFile = torrcFileTemp
    }
    
    if torrcFile.isEmpty {
      print("❌ torrcFile is empty")
    } else {
      print("Content of torrcFile: \(torrcFile)")
    }
    
    config.dataDirectory = URL(fileURLWithPath: torHiddenServiceDirectoryPath())
    config.arguments = ["-f", "\(torHiddenServiceDirectoryPath())/.torrc"]
    config.controlSocket = self.config.dataDirectory?.appendingPathComponent("cp")
    thread = TorThread(configuration: config)
    
    /// Инициализация контроллера
    if self.controller == nil, let socketURL = config.controlSocket {
      self.controller = TorController(socketURL: socketURL)
    }
  }
}

// MARK: - ClientOnionAuthDirectory

@available(iOS 13.0, *)
private extension TorHelper {
  /// Метод для создания директории авторизации
  func createAuthDirectory() -> String {
    let authPath = URL(
      fileURLWithPath: self.torHiddenServiceDirectoryPath(),
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
    } catch {
      print("❌ Auth directory previously created.")
    }
    return authPath
  }
  
  /// Удаляет все ключи авторизации и возвращает результат операции.
  @discardableResult
  func clearAuthKeys() -> Bool {
    let fileManager = FileManager.default
    do {
      let filePaths = try fileManager.contentsOfDirectory(atPath: authDirPath)
      for filePath in filePaths {
        let url = URL(fileURLWithPath: authDirPath + "/" + filePath)
        try fileManager.removeItem(at: url)
      }
      return true
    } catch {
      print("❌ Ошибка при удалении ключей: \(error)")
      return false
    }
  }
}


// MARK: - HiddenServiceDirectory

@available(iOS 13.0, *)
private extension TorHelper {
  /// Метод для создания директории для Tor
  @discardableResult
  func createTorHiddenServiceDirectory() -> Bool {
    let path = self.torHiddenServiceDirectoryPath()
    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: path) {
      do {
        try fileManager.createDirectory(
          atPath: path,
          withIntermediateDirectories: true,
          attributes: [FileAttributeKey.posixPermissions: 0o700]
        )
        print("✅ Directory created successfully at \(path).")
        return true
      } catch {
        print("❌ Failed to create directory at \(path): \(error)")
        return false
      }
    } else {
      print("✅ Directory already exists at \(path).")
      return true
    }
  }
  
  /// Метод для получения пути к директории Tor
  func torHiddenServiceDirectoryPath() -> String {
#if targetEnvironment(simulator)
    torHiddenServiceDirectoryPathSimulator()
#else
    torHiddenServiceDirectoryPathDevice()
#endif
  }
  
  /// Метод для получения пути к директории Tor
  func torHiddenServiceDirectoryPathSimulator() -> String {
    // Используем tmp директорию для хранения данных Tor, чтобы сократить путь
    let torDirPath = "/tmp/tor"
    
    // Проверяем существует ли директория и создаём если необходимо
    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: torDirPath) {
      do {
        try fileManager.createDirectory(atPath: torDirPath, withIntermediateDirectories: true, attributes: nil)
        print("✅ Tor directory created at \(torDirPath)")
      } catch {
        fatalError("❌ Failed to create tor directory at \(torDirPath): \(error)")
      }
    }
    
    return torDirPath
  }
  
  
  func torHiddenServiceDirectoryPathDevice() -> String {
    // Получаем путь к кэш-директории
    guard let cacheDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
      fatalError("❌ Unable to access the Caches directory")
    }
    
    // Строим путь к директории tor, используя полученный путь к кэш-директории
    let torDirPath = cacheDir.appending("/tor")
    
    // Проверяем существует ли директория и создаём если необходимо
    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: torDirPath) {
      do {
        try fileManager.createDirectory(atPath: torDirPath, withIntermediateDirectories: true, attributes: nil)
        print("✅ Tor directory created at \(torDirPath)")
      } catch {
        fatalError("❌ Failed to create tor directory at \(torDirPath): \(error)")
      }
    } else {
      print("✅ Directory already exists at \(torDirPath).")
    }
    
    return torDirPath
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
