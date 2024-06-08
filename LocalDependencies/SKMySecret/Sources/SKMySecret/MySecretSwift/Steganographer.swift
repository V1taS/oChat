//
//  Steganographer.swift
//
//
//  Created by Vitalii Sosin on 19.05.2024.
//

import Foundation
import UIKit

/// Протокол для выполнения операций стеганографии
public protocol ISteganographer {
  /// Тип завершения для кодирования с использованием Result
  typealias EncoderCompletionBlock = (Result<Data, StegoError>) -> Void
  /// Тип завершения для декодирования с использованием Result
  typealias DecoderCompletionBlock = (Result<String, StegoError>) -> Void
  
  /// Прячем текст в изображении
  /// - Parameters:
  ///   - textBase64: Текст в формате Base64, который нужно скрыть
  ///   - image: Данные изображения
  ///   - completionBlock: Блок завершения, вызываемый после завершения операции
  func hideTextBase64(_ textBase64: String?, withImage image: Data, completionBlock: @escaping EncoderCompletionBlock)
  
  /// Извлекаем скрытый текст из изображения
  /// - Parameters:
  ///   - image: Данные изображения
  ///   - completionBlock: Блок завершения, вызываемый после завершения операции
  func getTextBase64From(image: Data, completionBlock: @escaping DecoderCompletionBlock)
}

/// Класс для выполнения операций стеганографии
public final class Steganographer: ISteganographer {
  public init() {}
  
  public typealias EncoderCompletionBlock = ISteganographer.EncoderCompletionBlock
  public typealias DecoderCompletionBlock = ISteganographer.DecoderCompletionBlock
  
  /// Прячем текст в изображении
  /// - Parameters:
  ///   - textBase64: Текст в формате Base64, который нужно скрыть
  ///   - image: Данные изображения
  ///   - completionBlock: Блок завершения, вызываемый после завершения операции
  public func hideTextBase64(
    _ textBase64: String?,
    withImage image: Data,
    completionBlock: @escaping EncoderCompletionBlock
  ) {
    DispatchQueue.global().async {
      autoreleasepool {
        let encoder = StegoEncoder()
        do {
          let stegoImage = try encoder.stegoImage(for: image, textBase64: textBase64)
          if let stegoImage = stegoImage {
            DispatchQueue.main.async {
              completionBlock(.success(stegoImage))
            }
          } else {
            DispatchQueue.main.async {
              completionBlock(.failure(StegoError.noDataInImage))
            }
          }
        } catch {
          DispatchQueue.main.async {
            completionBlock(.failure(error as? StegoError ?? StegoError.notDefined))
          }
        }
      }
    }
  }
  
  /// Извлекаем скрытый текст из изображения
  /// - Parameters:
  ///   - image: Данные изображения
  ///   - completionBlock: Блок завершения, вызываемый после завершения операции
  public func getTextBase64From(image: Data, completionBlock: @escaping DecoderCompletionBlock) {
    DispatchQueue.global().async {
      autoreleasepool {
        let decoder = StegoDecoder()
        do {
          let data = try decoder.decodeStegoImage(image)
          if let data {
            DispatchQueue.main.async {
              completionBlock(.success(data.base64EncodedString()))
            }
          } else {
            DispatchQueue.main.async {
              completionBlock(.failure(StegoError.noDataInImage))
            }
          }
        } catch {
          DispatchQueue.main.async {
            completionBlock(.failure(error as? StegoError ?? StegoError.notDefined))
          }
        }
      }
    }
  }
}
