//
//  DataManagerService.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 28.11.2023.
//  Copyright © 2023 SosinVitalii.com. All rights reserved.
//

import Foundation
import SKAbstractions

// MARK: - Data Manager Service

public class DataManagerService: IDataManagerService {
  public init() {}
  
  // MARK: - Internal func
  
  public func saveObjectWith(
    fileName: String,
    fileExtension: String,
    data: Data
  ) -> URL? {
    let directoryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first
    let fileURL = directoryURL?.appendingPathComponent(fileName).appendingPathExtension(fileExtension)
    guard let fileURL else {
      return nil
    }
    
    do {
      try data.write(to: fileURL)
      return fileURL.absoluteURL
    } catch {
      return nil
    }
  }
  
  public func readObjectWith(fileURL: URL) -> Data? {
    do {
      return try Data(contentsOf: fileURL)
    } catch {
      return nil
    }
  }
  
  public func deleteObjectWith(fileURL: URL, isRemoved: ((Bool) -> Void)?) {
    do {
      try FileManager.default.removeItem(at: fileURL)
      isRemoved?(true)
    } catch {
      isRemoved?(false)
    }
  }
}
