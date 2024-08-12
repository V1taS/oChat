//
//  DeepLinkService.swift
//  SKServices
//
//  Created by Vitalii Sosin on 06.06.2024.
//

import Foundation
import SKAbstractions

/// Сервис для работы с глубокими ссылками.
public class DeepLinkService: IDeepLinkService {
  
  // MARK: - Private properties
  
  private let secureDataManagerService = SecureDataManagerService(.deepLinkService)
  
  // MARK: - Init
  
  public init() {}
  
  public func saveDeepLinkURL(_ url: URL) async {
    await withCheckedContinuation { continuation in
      secureDataManagerService.saveModel(url, for: Constants.deepLinkServiceKey)
      continuation.resume()
    }
  }
  
  public func deleteDeepLinkURL() {
    secureDataManagerService.deleteData(for: Constants.deepLinkServiceKey)
  }
  
  public func getMessengerAddress() async -> String? {
    await withCheckedContinuation { continuation in
      guard let deepLinkURL: URL = secureDataManagerService.getModel(for: Constants.deepLinkServiceKey),
            let address = getAddressFrom(url: deepLinkURL.absoluteString) else {
        continuation.resume(returning: nil)
        return
      }
      
      continuation.resume(returning: address)
    }
  }
}

// MARK: - Private

private extension DeepLinkService {
  func getAddressFrom(url: String) -> String? {
    guard url.hasPrefix(Constants.basePart) else {
      return nil
    }
    let remainingPart = String(url.dropFirst(Constants.basePart.count))
    return remainingPart
  }
}

// MARK: - Constants

private enum Constants {
  static let deepLinkServiceKey = String(describing: DeepLinkService.self)
  static let basePart = "onionChat://new_contact/"
}
