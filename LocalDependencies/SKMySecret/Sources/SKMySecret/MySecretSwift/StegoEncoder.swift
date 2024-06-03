//
//  StegoEncoder.swift
//
//
//  Created by Vitalii Sosin on 19.05.2024.
//

import UIKit
import CoreGraphics

/// Класс для кодирования данных в изображение с использованием стеганографии
final class StegoEncoder {
  /// Текущий сдвиг битов
  private var currentShift = StegoDefaults.INITIAL_SHIFT
  /// Текущий символ для кодирования
  private var currentCharacter = 0
  /// Шаг кодирования
  private var step: UInt32 = 0
  /// Текущие данные для сокрытия
  private var currentDataToHide: String = ""
  
  /// Кодирует данные в изображение
  /// - Parameters:
  ///   - image: Данные изображения
  ///   - textBase64: Данные в формате Base64 для сокрытия
  /// - Throws: Ошибка, если данные изображения недоступны или данные слишком велики
  /// - Returns: Данные изображения с закодированными данными
  func stegoImage(for image: Data, textBase64: String?) throws -> Data? {
    // Уменьшить размер изображения перед обработкой, чтобы не превышать 3 мегабайта
    let maxSizeInBytes = 3 * 1024 * 1024
    guard let resizedImageData = StegoUtilities.resizeImageIfNeeded(data: image, maxSizeInBytes: maxSizeInBytes) else {
      throw StegoError.imageTooSmall
    }
    
    guard let inputCGImage = StegoUtilities.cgImageCreate(with: resizedImageData) else {
      throw StegoError.imageTooSmall
    }
    
    let width = inputCGImage.width
    let height = inputCGImage.height
    let size = width * height
    var pixels = [UInt32](repeating: 0, count: size)
    
    guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else { return nil }
    
    guard let context = CGContext(
      data: &pixels,
      width: width,
      height: height,
      bitsPerComponent: StegoDefaults.BITS_PER_COMPONENT,
      bytesPerRow: StegoDefaults.BYTES_PER_PIXEL * width,
      space: colorSpace,
      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
    ) else { return nil }
    
    context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    
    if try hideData(textBase64, in: &pixels, withSize: size) {
      guard let newCGImage = context.makeImage() else { return nil }
      return StegoUtilities.image(from: newCGImage)
    } else {
      throw StegoError.dataTooBig
    }
  }
  
  /// Скрывает данные в массиве пикселей изображения
  /// - Parameters:
  ///   - textBase64: Данные в формате Base64 для сокрытия
  ///   - pixels: Массив пикселей изображения
  ///   - size: Размер массива пикселей
  /// - Throws: Ошибка, если данные слишком велики
  /// - Returns: true, если данные успешно скрыты
  private func hideData(_ textBase64: String?, in pixels: inout [UInt32], withSize size: Int) throws -> Bool {
    let messageToHide = try messageToHide(textBase64)
    let dataLength = UInt32(messageToHide.count)
    
    guard dataLength * UInt32(StegoDefaults.BITS_PER_COMPONENT) < size - StegoDefaults.sizeOfInfoLength() else {
      throw StegoError.dataTooBig
    }
    
    reset()
    
    let lengthData = withUnsafeBytes(of: dataLength) { Data($0) }
    let lengthDataInfo = String(data: lengthData, encoding: .ascii)!
    
    currentDataToHide = lengthDataInfo
    
    var pixelPosition = 0
    
    while pixelPosition < StegoDefaults.sizeOfInfoLength() {
      pixels[pixelPosition] = newPixel(pixels[pixelPosition])
      pixelPosition += 1
    }
    
    reset()
    
    let pixelsToHide = messageToHide.count * StegoDefaults.BITS_PER_COMPONENT
    currentDataToHide = messageToHide
    
    let ratio = Double(size - pixelPosition) / Double(pixelsToHide)
    let salt = Int(ratio)
    
    while pixelPosition < size {
      pixels[pixelPosition] = newPixel(pixels[pixelPosition])
      pixelPosition += salt
    }
    
    return true
  }
  
  /// Создает новый пиксель с закодированными данными
  /// - Parameter pixel: Исходный пиксель
  /// - Returns: Новый пиксель с закодированными данными
  private func newPixel(_ pixel: UInt32) -> UInt32 {
    let color = newColor(pixel)
    step += 1
    return color
  }
  
  /// Создает новый цвет с закодированными данными
  /// - Parameter color: Исходный цвет
  /// - Returns: Новый цвет с закодированными данными
  private func newColor(_ color: UInt32) -> UInt32 {
    if currentDataToHide.count > currentCharacter {
      let index = currentDataToHide.index(currentDataToHide.startIndex, offsetBy: currentCharacter)
      let asciiCode = UInt32(currentDataToHide[index].asciiValue!)
      let shiftedBits = asciiCode >> currentShift
      
      if currentShift == 0 {
        currentShift = StegoDefaults.INITIAL_SHIFT
        currentCharacter += 1
      } else {
        currentShift -= 1
      }
      return PixelUtilities.newPixel(color, shiftedBits: shiftedBits, shift: PixelUtilities.colorToStep(step).rawValue)
    }
    return color
  }
  
  /// Сбрасывает текущие параметры кодирования
  private func reset() {
    currentShift = StegoDefaults.INITIAL_SHIFT
    currentCharacter = 0
  }
  
  /// Формирует сообщение для сокрытия, добавляя префикс и суффикс
  /// - Parameter textBase64: Данные в формате Base64
  /// - Throws: Ошибка, если данные отсутствуют
  /// - Returns: Сообщение для сокрытия
  private func messageToHide(_ textBase64: String?) throws -> String {
    guard let base64 = textBase64 else {
      throw StegoError.dataTooBig
    }
    return "\(StegoDefaults.DATA_PREFIX)\(base64)\(StegoDefaults.DATA_SUFFIX)"
  }
}
