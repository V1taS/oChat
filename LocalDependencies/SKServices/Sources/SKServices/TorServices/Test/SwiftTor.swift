import Tor

@available(iOS 16.0, macOS 13, *)
public class SwiftTor: ObservableObject {
  public var tor: TorHelper
  
  @Published public var state = TorState.none
  
  public init(hiddenServicePort: Int? = nil, start: Bool = true) {
    self.tor = TorHelper()
    self.tor.hiddenServicePort = hiddenServicePort
    if start {
      self.start()
    }
    Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
      self.state = self.tor.state
    }
    if hiddenServicePort != nil {
      Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
        self.onionAddress = self.tor.onionAddress
      }
    }
  }
  
  public var started = false
  
  public func start() {
    if started == false {
      tor.start(delegate: nil)
      started = true
    }
  }
  
  @Published public var onionAddress: String? = nil
  
  enum TorError: Error {
    case notConnectedTimeout
  }
  
  public func restart() {
    self.state = .none
    self.tor.resign()
    self.tor = TorHelper()
    tor.start(delegate: nil)
  }
  
  private var session: URLSession {
    tor.session
  }
  
  private func doRequest(request: URLRequest, index: Int) async throws -> (Data, URLResponse) {
    if self.tor.state == .connected {
      return try await tor.session.data(for: request)
    }else {
      if started == false {
        self.start()
      }
      if index < 21 {
        try await Task.sleep(nanoseconds: 1000000000)
        return try await doRequest(request: request, index: index + 1)
      }else {
        throw TorError.notConnectedTimeout
      }
    }
  }
  
  public func request(request: URLRequest) async throws -> (Data, URLResponse) {
    try await doRequest(request: request, index: 1)
  }
}