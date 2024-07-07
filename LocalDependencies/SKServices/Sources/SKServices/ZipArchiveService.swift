//
//  ZipArchiveService.swift
//  SKServices
//
//  Created by Vitalii Sosin on 02.07.2024.
//

import Foundation
import Zip
import SKAbstractions

// MARK: - CryptoService

public final class ZipArchiveService: IZipArchiveService {
  
  // Инициализатор
  public init() {}
  
  // Метод для архивирования файлов
  public func zipFiles(
    atPaths paths: [URL],
    toDestination destinationPath: URL,
    password: String? = nil,
    progress: ((_ progress: Double) -> ())? = nil
  ) throws {
    do {
      try Zip.zipFiles(
        paths: paths,
        zipFilePath: destinationPath,
        password: password,
        compression: .BestCompression,
        progress: progress
      )
    } catch {
      throw error
    }
  }
  
  // Метод для разархивирования файлов
  public func unzipFile(
    atPath path: URL,
    toDestination destinationPath: URL,
    overwrite: Bool = true,
    password: String? = nil,
    progress: ((_ progress: Double) -> ())? = nil,
    fileOutputHandler: ((_ unzippedFile: URL) -> Void)? = nil
  ) throws {
    do {
      try Zip.unzipFile(
        path,
        destination: destinationPath,
        overwrite: overwrite,
        password: password,
        progress: progress,
        fileOutputHandler: fileOutputHandler
      )
    } catch {
      throw error
    }
  }
}
