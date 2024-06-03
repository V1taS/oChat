//
//  SteganographyService.swift
//  oChat
//
//  Created by Vitalii Sosin on 26.02.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SwiftUI
import SKMySecret
import SKAbstractions

// MARK: - Steganography Service

public final class SteganographyService: ISteganographyService {
  public init() {}
  
  private let processor: ISteganographer = Steganographer()
  
  public func hideTextBase64(
    _ textBase64: String?,
    withImage image: Data,
    completionBlock: @escaping EncoderCompletionBlock
  ) {
    processor.hideTextBase64(textBase64, withImage: image) { result in
      switch result {
      case let .success(imageData):
        completionBlock(.success(imageData))
      case let .failure(error):
        completionBlock(.failure(error.mapTo()))
      }
    }
  }
  
  public func getTextBase64From(image: Data, completionBlock: @escaping DecoderCompletionBlock) {
    processor.getTextBase64From(image: image) { result in
      switch result {
      case let .success(textBase64):
        completionBlock(.success(textBase64))
      case let .failure(error):
        completionBlock(.failure(error.mapTo()))
      }
    }
  }
}

// MARK: - Mapping

extension StegoError {
  func mapTo() -> SteganographyServiceProcessingError {
    switch self {
    case .notDefined:
      return .notDefined
    case .dataTooBig:
      return .dataTooBig
    case .imageTooSmall:
      return .imageTooSmall
    case .noDataInImage:
      return .noDataInImage
    }
  }
}
