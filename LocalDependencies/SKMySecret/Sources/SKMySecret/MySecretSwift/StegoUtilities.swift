//
//  StegoUtilities.swift
//
//
//  Created by Vitalii Sosin on 19.05.2024.
//

import UIKit
import CoreGraphics

/// Утилиты для стеганографии
enum StegoUtilities {
  /// Проверяет, содержит ли строка заданную подстроку
  /// - Parameters:
  ///   - string: Исходная строка
  ///   - substring: Подстрока для поиска
  /// - Returns: true, если строка содержит подстроку, иначе false
  static func contains(_ string: String, substring: String) -> Bool {
    return string.range(of: substring, options: .caseInsensitive) != nil
  }
  
  /// Извлекает подстроку между заданными префиксом и суффиксом
  /// - Parameters:
  ///   - string: Исходная строка
  ///   - prefix: Префикс
  ///   - suffix: Суффикс
  /// - Returns: Извлеченная подстрока или nil, если префикс или суффикс не найдены
  static func substring(_ string: String, prefix: String, suffix: String) -> String? {
    guard let prefixRange = string.range(of: prefix), let suffixRange = string.range(of: suffix, range: prefixRange.upperBound..<string.endIndex) else {
      return nil
    }
    return String(string[prefixRange.upperBound..<suffixRange.lowerBound])
  }
  
  /// Создает CGImage из данных изображения
  /// - Parameter image: Данные изображения
  /// - Returns: CGImage или nil, если создание изображения не удалось
  static func cgImageCreate(with image: Data) -> CGImage? {
#if canImport(UIKit)
    guard let uiImage = UIImage(data: image) else { return nil }
    return uiImage.cgImage
#elseif canImport(AppKit)
    guard let nsImage = image as? NSImage else { return nil }
    guard let data = nsImage.tiffRepresentation else { return nil }
    guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
    return CGImageSourceCreateImageAtIndex(source, 0, nil)
#else
    return nil
#endif
  }
  
  /// Создает данные изображения из CGImage
  /// - Parameter cgImage: CGImage
  /// - Returns: Данные изображения или nil, если создание данных не удалось
  static func image(from cgImage: CGImage) -> Data? {
#if canImport(UIKit)
    return UIImage(cgImage: cgImage).pngData()
#elseif canImport(AppKit)
    return NSImage(cgImage: cgImage, size: NSZeroSize)
#endif
  }
  
  /// Проверяет и изменяет разрешение изображения, чтобы оно не превышало заданный размер
  /// - Parameters:
  ///   - image: Данные изображения
  ///   - maxSizeInBytes: Максимальный размер данных изображения в байтах
  /// - Returns: Данные изображения с измененным разрешением
  static func resizeImageIfNeeded(data: Data, maxSizeInBytes: Int) -> Data? {
    guard let image = UIImage(data: data) else { return nil }
    let bytesPerPixel = StegoDefaults.BYTES_PER_PIXEL
    let maxPixels = maxSizeInBytes / bytesPerPixel
    
    let currentWidth = image.size.width
    let currentHeight = image.size.height
    let currentPixels = Int(currentWidth * currentHeight)
    
    guard currentPixels > maxPixels else { return data }
    
    let scaleFactor = sqrt(Double(maxPixels) / Double(currentPixels))
    let targetWidth = currentWidth * CGFloat(scaleFactor)
    let targetHeight = currentHeight * CGFloat(scaleFactor)
    let size = CGSize(width: targetWidth, height: targetHeight)
    
    UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
    image.draw(in: CGRect(origin: .zero, size: size))
    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return resizedImage?.pngData()
  }
}
