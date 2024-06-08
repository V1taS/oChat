//
//  AnalyticsService.swift
//  SKServices
//
//  Created by Vitalii Sosin on 10.05.2024.
//

import OSLog
import Foundation
import SKAbstractions

/// Класс `AnalyticsService` реализует протокол `IAnalyticsService`, предоставляя функциональность для отслеживания событий.
public class AnalyticsService: IAnalyticsService {
  /// Инициализатор класса `AnalyticsService`.
  public init() {}
  
  public func trackEvent(_ event: String, parameters: [String: Any]) {}
  
  public func log(_ message: String) {
    Logger().log("SafeKeeper| \(message)")
  }
  
  public func error(
    _ error: String,
    file: String = #file,
    function: String = #function,
    line: Int = #line
  ) {
    Logger().log(
      level: .error,
      "\n============\nSafeKeeper| Error: \(error)\nFunc: \(function)\nFile: \(self.fileName(from: file))\nLine: \(line)\n============\n"
    )
  }
  
  public func error(
    _ error: Error,
    file: String = #file,
    function: String = #function,
    line: Int = #line
  ) {
    Logger().log(level: .error, "\n============\nSafeKeeper| Error \nFunc: \(function)\nFile: \(self.fileName(from: file))\nLine: \(line)\nError: \(error.localizedDescription)\n============\n")
  }
  
  public func getAllLogs() -> URL? {
    guard let logFileURL else {
      return nil
    }
    return FileManager.default.fileExists(atPath: logFileURL.path) ? logFileURL : nil
  }
  
  public func getErrorLogs() -> URL? {
    guard let errorLogFileURL else {
      return nil
    }
    return FileManager.default.fileExists(atPath: errorLogFileURL.path) ? errorLogFileURL : nil
  }
  
  public func clearAllLogs() {
    do {
      if let allLogsURL = self.logFileURL, FileManager.default.fileExists(atPath: allLogsURL.path) {
        try FileManager.default.removeItem(at: allLogsURL)
        print("✅ All logs have been cleared.")
      }
      
      if let errorLogsURL = self.errorLogFileURL, FileManager.default.fileExists(atPath: errorLogsURL.path) {
        try FileManager.default.removeItem(at: errorLogsURL)
        print("✅ Error logs have been cleared.")
      }
    } catch {
      print("❌ Failed to clear logs: \(error)")
    }
  }
}

// MARK: - Private

private extension AnalyticsService {
  var logFileURL: URL? {
    let directoryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first
    let logsDirectory = directoryURL?.appendingPathComponent("Logs")
    let logFileURL = logsDirectory?.appendingPathComponent("allLogs.txt")
    return logFileURL
  }
  
  var errorLogFileURL: URL? {
    let directoryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first
    let logsDirectory = directoryURL?.appendingPathComponent("Logs")
    let errorLogFileURL = logsDirectory?.appendingPathComponent("errorLogs.txt")
    return errorLogFileURL
  }
  
  func appendLog(_ message: String, to fileURL: URL) {
    do {
      if !FileManager.default.fileExists(atPath: fileURL.path) {
        try "".write(to: fileURL, atomically: true, encoding: .utf8)
      }
      let fileHandle = try FileHandle(forWritingTo: fileURL)
      fileHandle.seekToEndOfFile()
      let fullMessage = "\(Date()): \(message)\n"
      if let data = fullMessage.data(using: .utf8) {
        fileHandle.write(data)
      }
      fileHandle.closeFile()
    } catch {
      print("❌ Failed to log message: \(error)")
    }
  }
  
  func fileName(from path: String) -> String {
    path.components(separatedBy: "/").last ?? ""
  }
}
