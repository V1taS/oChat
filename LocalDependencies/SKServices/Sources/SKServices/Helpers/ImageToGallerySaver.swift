//
//  ImageToGallerySaver.swift
//  SKServices
//
//  Created by Vitalii Sosin on 26.04.2024.
//

import Foundation
import UIKit
import Photos

final class MediaToGallerySaver: NSObject {
  
  // MARK: - Init
  
  override init() {}
  
  // MARK: - Private properties
  
  private var statusAction: ((_ isSuccess: Bool) -> Void)?
  
  // MARK: - Internal funcs
  
  // Сохранение изображения в галерею
  func saveImageToGallery(_ imageData: Data?) async -> Bool {
    await withCheckedContinuation { continuation in
      guard let imageData, let image = UIImage(data: imageData) else {
        continuation.resume(returning: false)
        return
      }
      
      // Сохраняем изображение в альбом
      UIImageWriteToSavedPhotosAlbum(
        image,
        self,
        #selector(image(_:didFinishSavingWithError:contextInfo:)),
        nil
      )
      
      // Определяем результат сохранения в селекторе
      self.statusAction = { isSuccess in
        continuation.resume(returning: isSuccess)
      }
    }
  }
  
  // Сохранение видео в галерею
  func saveVideoToGallery(_ videoURL: URL?) async -> Bool {
    await withCheckedContinuation { continuation in
      guard let videoURL = videoURL else {
        continuation.resume(returning: false)
        return
      }
      
      // Проверяем доступ к фотогалерее
      PHPhotoLibrary.requestAuthorization { status in
        guard status == .authorized else {
          continuation.resume(returning: false)
          return
        }
        
        // Начинаем сохранение видео в альбом
        PHPhotoLibrary.shared().performChanges({
          PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
        }) { success, error in
          if let error = error {
            print("Error saving video: \(error)")
            continuation.resume(returning: false)
          } else {
            continuation.resume(returning: success)
          }
        }
      }
    }
  }
}

// MARK: - Private

private extension MediaToGallerySaver {
  @objc
  func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
    if error != nil {
      statusAction?(false)
    } else {
      statusAction?(true)
    }
  }
}
