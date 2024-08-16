//
//  FileManager.swift
//
//
//  Created by Sosin Vitalii on 02.06.2023.
//

import SwiftUI
import AVFoundation

extension FileManager {
  
  static var tempPath: URL {
    URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
  }
  
  static var imageFileExtension: String { ".jpg" }
  static var videoFileExtension: String { ".mp4" }
  
  static func storeToTempDir(url: URL) -> URL {
    let id = UUID().uuidString
    let path = FileManager.tempPath.appendingPathComponent(id + Self.imageFileExtension)
    
    try? FileManager.default.copyItem(at: url, to: path)
    return path
  }
  
  static func storeToTempDir(data: Data) -> URL {
    let id = UUID().uuidString
    let path = FileManager.tempPath.appendingPathComponent(id + Self.imageFileExtension)
    
    try? data.write(to: path)
    return path
  }
  
  static func getTempUrl() -> URL {
    let id = UUID().uuidString
    return FileManager.tempPath.appendingPathComponent(id + Self.videoFileExtension)
  }
}
