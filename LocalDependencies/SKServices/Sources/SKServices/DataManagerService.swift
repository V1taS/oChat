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
  
  public func saveObjectWith(tempURL: URL) -> URL? {
    guard let objectData = readObjectWith(fileURL: tempURL) else {
      return nil
    }
    
    // Получение расширения файла
    let fileExtension = tempURL.pathExtension
    
    let directoryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first
    let fileURL = directoryURL?.appendingPathComponent(UUID().uuidString.lowercased()).appendingPathExtension(fileExtension)
    guard let fileURL else {
      return nil
    }
    
    do {
      try objectData.write(to: fileURL)
      return fileURL.absoluteURL
    } catch {
      return nil
    }
  }
  
  public func clearTemporaryDirectory() {
    let tempDirectory = FileManager.default.temporaryDirectory
    
    do {
      let tempDirectoryContents = try FileManager.default.contentsOfDirectory(
        at: tempDirectory,
        includingPropertiesForKeys: nil,
        options: []
      )
      for file in tempDirectoryContents {
        try FileManager.default.removeItem(at: file)
      }
    } catch {
      print("Error clearing temporary directory: \(error)")
    }
  }
  
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
  
  public func saveObjectToCachesWith(
    fileName: String,
    fileExtension: String,
    data: Data
  ) -> URL? {
    let directoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
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
    if let object = FileManager.default.contents(atPath: fileURL.path()) {
      return object
    }
    if let object = try? Data(contentsOf: fileURL) {
      return object
    }
    return nil
  }
  
  public func constructFileURL(fileName: String, fileExtension: String? = nil) -> URL? {
    let directoryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first
    guard let directoryURL else {
      return nil
    }
    
    var fullFileName = fileName
    if let fileExtension = fileExtension, !fileName.hasSuffix(".\(fileExtension)") {
      fullFileName = "\(fileName).\(fileExtension)"
    }
    
    return directoryURL.appendingPathComponent(fullFileName)
  }
  
  public func getFileName(from url: URL) -> String? {
    return url.lastPathComponent
  }
  
  public func getFileNameWithoutExtension(from url: URL) -> String {
    return (url.lastPathComponent as NSString).deletingPathExtension
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
