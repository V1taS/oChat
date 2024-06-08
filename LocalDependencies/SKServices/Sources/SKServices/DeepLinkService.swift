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
  
  public func saveDeepLinkURL(_ url: URL, completion: (() -> Void)?) {
    secureDataManagerService.saveModel(url, for: Constants.deepLinkServiceKey)
    completion?()
  }
  
  public func deleteDeepLinkURL() {
    secureDataManagerService.deleteData(for: Constants.deepLinkServiceKey)
  }
  
  public func getMessengerAdress(completion: ((_ adress: String?) -> Void)?) {
    guard let deepLinkURL: URL = secureDataManagerService.getModel(for: Constants.deepLinkServiceKey),
          let adress = getAdressFrom(url: deepLinkURL.absoluteString) else {
      completion?(nil)
      return
    }
    
    
    completion?(adress)
  }
}

// MARK: - Private

private extension DeepLinkService {
  func getAdressFrom(url: String) -> String? {
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
  static let basePart = "oChatTOR://new_contact/"
}
