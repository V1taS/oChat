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
  override init() {}
  
  private var statusAction: ((_ isSuccess: Bool) -> Void)?
  
  // Сохранение изображения в галерею
  func saveImageToGallery(_ imageData: Data?, completion: ((_ isSuccess: Bool) -> Void)?) {
    statusAction = completion
    
    guard let imageData, let image = UIImage(data: imageData) else {
      completion?(false)
      return
    }
    UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
  }
  
  @objc
  private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
    if error != nil {
      statusAction?(false)
    } else {
      statusAction?(true)
    }
  }
  
  // Сохранение видео в галерею
  func saveVideoToGallery(_ videoURL: URL?, completion: ((_ isSuccess: Bool) -> Void)?) {
    statusAction = completion
    
    guard let videoURL = videoURL else {
      completion?(false)
      return
    }
    
    // Проверяем доступ к фотогалерее
    PHPhotoLibrary.requestAuthorization { status in
      guard status == .authorized else {
        DispatchQueue.main.async {
          completion?(false)
        }
        return
      }
      
      // Начинаем сохранение видео в альбом
      PHPhotoLibrary.shared().performChanges({
        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
      }) { success, error in
        DispatchQueue.main.async {
          if let error = error {
            print("Error saving video: \(error)")
            completion?(false)
          } else {
            completion?(true)
          }
        }
      }
    }
  }
}
