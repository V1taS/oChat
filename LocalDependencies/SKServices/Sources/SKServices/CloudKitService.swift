//
//  CloudKitService.swift
//  SKServices
//
//  Created by Vitalii Sosin on 12.05.2024.
//

import Foundation
import CloudKit
import SKAbstractions

// MARK: - CloudKitService

public final class CloudKitService: ICloudKitService {
  /// Инициализирует новый экземпляр CloudKitService.
  public init() {}
  
  public func getConfigurationValue<T>(from keyName: String) async throws -> T? {
    return try await withCheckedThrowingContinuation { continuation in
      let container = CKContainer(identifier: "iCloud.com.sosinvitalii.oChat")
      let publicDatabase = container.publicCloudDatabase
      let predicate = NSPredicate(value: true)
      let query = CKQuery(recordType: "Config", predicate: predicate)
      
      publicDatabase.fetch(withQuery: query) { result in
        switch result {
        case .success(let success):
          guard case let .success(record) = success.matchResults.first?.1,
                let value = record[keyName] as? T else {
            continuation.resume(returning: nil)
            return
          }
          continuation.resume(returning: value)
          
        case .failure(let error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
}
