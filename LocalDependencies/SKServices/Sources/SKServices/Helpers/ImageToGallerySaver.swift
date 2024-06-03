//
//  ImageToGallerySaver.swift
//  SKServices
//
//  Created by Vitalii Sosin on 26.04.2024.
//

import Foundation
import UIKit

final class ImageToGallerySaver: NSObject {
  override init() {}
  
  private var statusAction: ((_ isSuccess: Bool) -> Void)?
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
}

