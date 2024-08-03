//
//  FileManager.swift
//  SKManagers
//
//  Created by Vitalii Sosin on 03.08.2024.
//

import SwiftUI
import SKAbstractions
import SKStyle
import SKFoundation
import AVFoundation

public protocol ISKFileManager {
  func saveObjectToCachesWith(fileName: String, fileExtension: String, data: Data) -> URL?
  func saveObjectWith(fileName: String, fileExtension: String, data: Data) -> URL?
  func readObjectWith(fileURL: URL) -> Data?
  func clearTemporaryDirectory()
  func saveObjectWith(tempURL: URL) -> URL?
  func getFileName(from url: URL) -> String?
  func getFileNameWithoutExtension(from url: URL) -> String
  func getFirstFrame(from url: URL) -> Data?
  func resizeThumbnailImageWithFrame(data: Data) -> Data?
  func receiveAndUnzipFile(zipFileURL: URL, password: String) async throws -> (
    model: MessengerNetworkRequestModel,
    recordingDTO: MessengeRecordingDTO?,
    files: [URL]
  )
}

public final class SKFileManager: ISKFileManager {
  
  // MARK: - Private properties
  
  private let dataManagementService: IDataManagerService
  private let zipArchiveService: IZipArchiveService
  
  // MARK: - Init
  
  public init(
    dataManagementService: IDataManagerService,
    zipArchiveService: IZipArchiveService
  ) {
    self.dataManagementService = dataManagementService
    self.zipArchiveService = zipArchiveService
  }
  
  // MARK: - Public funcs
  
  public func saveObjectToCachesWith(fileName: String, fileExtension: String, data: Data) -> URL? {
    return dataManagementService.saveObjectToCachesWith(fileName: fileName, fileExtension: fileExtension, data: data)
  }
  
  public func saveObjectWith(fileName: String, fileExtension: String, data: Data) -> URL? {
    return dataManagementService.saveObjectWith(fileName: fileName, fileExtension: fileExtension, data: data)
  }
  
  public func readObjectWith(fileURL: URL) -> Data? {
    return dataManagementService.readObjectWith(fileURL: fileURL)
  }
  
  public func clearTemporaryDirectory() {
    dataManagementService.clearTemporaryDirectory()
  }
  
  public func saveObjectWith(tempURL: URL) -> URL? {
    return dataManagementService.saveObjectWith(tempURL: tempURL)
  }
  
  public func getFileName(from url: URL) -> String? {
    return dataManagementService.getFileName(from: url)
  }
  
  public func getFileNameWithoutExtension(from url: URL) -> String {
    return dataManagementService.getFileNameWithoutExtension(from: url)
  }
  
  public func getFirstFrame(from url: URL) -> Data? {
    let asset = AVAsset(url: url)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    
    let time = CMTime(seconds: 1, preferredTimescale: 600)
    do {
      let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
      let uiImage = UIImage(cgImage: cgImage)
      if let imageData = uiImage.jpegData(compressionQuality: 1.0) {
        return imageData
      }
    } catch {
      print("Error extracting image from video: \(error.localizedDescription)")
    }
    return nil
  }
  
  public func resizeThumbnailImageWithFrame(data: Data) -> Data? {
    guard let originalImage = UIImage(data: data) else { return nil }
    
    let targetSize = CGSize(width: 200, height: 200)
    
    let widthRatio = targetSize.width / originalImage.size.width
    let heightRatio = targetSize.height / originalImage.size.height
    let scaleFactor = max(widthRatio, heightRatio)
    
    let scaledImageSize = CGSize(
      width: originalImage.size.width * scaleFactor,
      height: originalImage.size.height * scaleFactor
    )
    
    let renderer = UIGraphicsImageRenderer(size: targetSize)
    let framedImage = renderer.image { context in
      let origin = CGPoint(
        x: (targetSize.width - scaledImageSize.width) / 2,
        y: (targetSize.height - scaledImageSize.height) / 2
      )
      originalImage.draw(in: CGRect(origin: origin, size: scaledImageSize))
    }
    
    return framedImage.pngData()
  }
  
  public func receiveAndUnzipFile(
    zipFileURL: URL,
    password: String
  ) async throws -> (model: MessengerNetworkRequestModel, recordingDTO: MessengeRecordingDTO?, files: [URL]) {
    return try await withCheckedThrowingContinuation { continuation in
      DispatchQueue.global().async { [weak self] in
        guard let self else { return }
        // Для получения директории Documents
        guard let documentDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
          print("Ошибка: не удалось получить путь к директории Documents")
          continuation.resume(throwing: URLError(.cannotFindHost)) // Используем подходящий URLError
          return
        }
        let destinationURL = documentDirectory.appendingPathComponent(UUID().uuidString)
        
        var model: MessengerNetworkRequestModel?
        var recordingModel: MessengeRecordingDTO?
        var fileURLs: [URL] = []
        
        do {
          try zipArchiveService.unzipFile(
            atPath: zipFileURL,
            toDestination: destinationURL,
            overwrite: true,
            password: password,
            progress: nil
          ) { unzippedFile in
            print("Unzipped file: \(unzippedFile)")
            
            if unzippedFile.pathExtension == "model" {
              if let modelData = FileManager.default.contents(atPath: unzippedFile.path()) {
                let decoder = JSONDecoder()
                guard let dto = try? decoder.decode(MessengerNetworkRequestDTO.self, from: modelData) else {
                  continuation.resume(throwing: URLError(.cannotDecodeContentData))
                  return
                }
                model = dto.mapToModel()
              } else {
                print("Не удалось прочитать данные из файла")
              }
            } else if unzippedFile.pathExtension == "record" {
              if let modelData = FileManager.default.contents(atPath: unzippedFile.path()) {
                let decoder = JSONDecoder()
                guard let model = try? decoder.decode(MessengeRecordingDTO.self, from: modelData) else {
                  continuation.resume(throwing: URLError(.cannotDecodeContentData))
                  return
                }
                recordingModel = model
              } else {
                print("Не удалось прочитать данные из файла")
              }
            } else {
              fileURLs.append(unzippedFile)
            }
          }
          
          guard let model else {
            continuation.resume(throwing: URLError(.unknown))
            return
          }
          
          continuation.resume(returning: (model, recordingModel, fileURLs))
        } catch {
          continuation.resume(throwing: error)
        }
      }
    }
  }
}
