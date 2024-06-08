//
//  ISteganographyService.swift
//
//
//  Created by Vitalii Sosin on 26.02.2024.
//

import Foundation

/// Сервис по работе с стеганографией в изображении
public protocol ISteganographyService {
  /// Тип завершения для кодирования с использованием Result
  typealias EncoderCompletionBlock = (Result<Data, SteganographyServiceProcessingError>) -> Void
  /// Тип завершения для декодирования с использованием Result
  typealias DecoderCompletionBlock = (Result<String, SteganographyServiceProcessingError>) -> Void
  
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
