//
//  SecureDataManagerService.swift
//  SKServices
//
//  Created by Vitalii Sosin on 10.05.2024.
//

import Foundation
import SKAbstractions

public struct SecureDataManagerService: ISecureDataManagerService {
  
  // MARK: - Private properties
  
  private let serviceName: String
  
  // MARK: - Init
  
  /// Инициализирует новый экземпляр сервиса с указанным названием.
  /// - Parameter serviceName: Название сервиса, используемое для хранения данных.
  public init(_ serviceName: SecureDataManagerServiceKey) {
    self.serviceName = serviceName.rawValue
  }
  
  // MARK: - Public func
  
  public func getString(for key: String) -> String? {
    guard let data = getData(for: key),
          let string = String(data: data, encoding: .utf8) else {
      return nil
    }
    return string
  }
  
  public func getData(for key: String) -> Data? {
    let request = requestForKey(key)
    var dataTypeRef: CFTypeRef?
    let status: OSStatus = SecItemCopyMatching(request, &dataTypeRef)
    
    switch status {
    case errSecSuccess:
      return dataTypeRef as? Data
    default:
      return nil
    }
  }
  
  public func getModel<T: Decodable>(for key: String) -> T? {
    guard
      let data = getData(for: key),
      let model = try? JSONDecoder().decode(T.self, from: data)
    else {
      return nil
    }
    return model
  }
  
  @discardableResult
  public func saveModel<T: Encodable>(_ model: T, for key: String) -> Bool {
    if let encoded = try? JSONEncoder().encode(model) {
      return saveData(encoded, key: key)
    }
    return false
  }
  
  @discardableResult
  public func saveString(_ string: String, key: String) -> Bool {
    guard let data = string.data(using: .utf8) else {
      return false
    }
    return saveData(data, key: key)
  }
  
  @discardableResult
  public func saveData(_ data: Data, key: String) -> Bool {
    guard let attributes = attributes(for: data, key: key) else {
      return false
    }
    let status: OSStatus = SecItemAdd(attributes, nil)
    
    switch status {
    case errSecSuccess:
      return true
    case errSecDuplicateItem:
      guard deleteData(for: key) else {
        return false
      }
      return saveData(data, key: key)
    default:
      return false
    }
  }
  
  @discardableResult
  public func deleteData(for key: String) -> Bool {
    let request = deletionRequestForKey(key)
    let status: OSStatus = SecItemDelete(request)
    return status == errSecSuccess
  }
  
  @discardableResult
  public func deleteAllData() -> Bool {
    var isDeleteSuccess = true
    
    SecureDataManagerServiceKey.itemsToClear.forEach { serviceKey in
      let request = deleteAllRequest(serviceName: serviceKey.rawValue)
      let status: OSStatus = SecItemDelete(request)
      
      if status != errSecSuccess {
        isDeleteSuccess = false
      }
    }
    
    return isDeleteSuccess
  }
}

// MARK: - Private

private extension SecureDataManagerService {
  func requestForKey(_ key: String) -> CFDictionary {
    [
      kSecReturnData: true,
      kSecAttrAccount: key,
      kSecAttrService: serviceName,
      kSecMatchLimit: kSecMatchLimitOne,
      kSecClass: kSecClassGenericPassword
    ] as CFDictionary
  }
  
  func deletionRequestForKey(_ key: String) -> CFDictionary {
    [
      kSecAttrAccount: key,
      kSecAttrService: serviceName,
      kSecClass: kSecClassGenericPassword
    ] as CFDictionary
  }
  
  func attributes(for data: Data, key: String) -> CFDictionary? {
    [
      kSecValueData: data,
      kSecAttrAccount: key,
      kSecAttrService: serviceName,
      kSecClass: kSecClassGenericPassword,
      kSecAttrAccessible: kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
    ] as CFDictionary
  }
  
  func deleteAllRequest(serviceName: String) -> CFDictionary {
    [
      kSecClass: kSecClassGenericPassword,
      kSecAttrService: serviceName
    ] as CFDictionary
  }
}
