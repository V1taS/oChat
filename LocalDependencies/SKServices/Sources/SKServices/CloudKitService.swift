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
  
  public func getConfigurationValue<T>(from keyName: String, completion: @escaping (_ value: T?) -> Void) {
    let container = CKContainer(identifier: "iCloud.com.sosinvitalii.SafeKeeper")
    let publicDatabase = container.publicCloudDatabase
    let predicate = NSPredicate(value: true)
    let query = CKQuery(recordType: "Config", predicate: predicate)
    
    publicDatabase.fetch(withQuery: query) { result in
      if case let .success(success) = result,
         case let .success(record) = success.matchResults.first?.1,
         let value = record[keyName] as? T {
        DispatchQueue.main.async {
          completion(value)
        }
      } else {
        DispatchQueue.main.async {
          completion(nil)
        }
      }
    }
  }
}
