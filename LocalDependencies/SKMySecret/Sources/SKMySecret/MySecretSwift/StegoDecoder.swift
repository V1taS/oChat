//
//  StegoDecoder.swift
//
//
//  Created by Vitalii Sosin on 19.05.2024.
//

import Foundation
import CoreGraphics
import UIKit

/// Класс для декодирования стеганографических изображений
final class StegoDecoder {
  /// Текущий сдвиг битов
  private var currentShift = StegoDefaults.INITIAL_SHIFT
  /// Биты символа
  private var bitsCharacter = 0
  /// Закодированные данные в виде строки
  private var data: String = ""
  /// Шаг декодирования
  private var step: UInt32 = 0
  /// Длина закодированного сообщения
  private var length: UInt32 = 0
  
  /// Декодирует стеганографическое изображение
  /// - Parameter image: Данные изображения
  /// - Throws: Ошибка, если данные изображения недоступны
  /// - Returns: Декодированные данные
  func decodeStegoImage(_ image: Data) throws -> Data? {
    guard let inputCGImage = StegoUtilities.cgImageCreate(with: image) else {
      throw StegoError.noDataInImage
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
    
    searchData(in: pixels, withSize: size)
    
    return hasData() ? Data(
      base64Encoded: StegoUtilities.substring(
        data,
        prefix: StegoDefaults.DATA_PREFIX,
        suffix: StegoDefaults.DATA_SUFFIX
      ) ?? ""
    ) : nil
  }
  
  /// Ищет закодированные данные в пикселях изображения
  /// - Parameters:
  ///   - pixels: Массив пикселей изображения
  ///   - size: Размер массива пикселей
  private func searchData(in pixels: [UInt32], withSize size: Int) {
    reset()
    var pixelPosition = 0
    
    // Ищем длину закодированного сообщения
    while pixelPosition < StegoDefaults.sizeOfInfoLength() {
      getDataFrom(pixel: pixels[pixelPosition])
      pixelPosition += 1
    }
    
    reset()
    let pixelsToHide = Int(length) * StegoDefaults.BITS_PER_COMPONENT
    let ratio = Double(size - pixelPosition) / Double(pixelsToHide)
    let salt = Int(ratio)
    var stepCounter = 0
    let maxSteps = 15_000
    
    while pixelPosition < size && stepCounter < maxSteps {
      getDataFrom(pixel: pixels[pixelPosition])
      pixelPosition += salt
      stepCounter += 1
      
      if StegoUtilities.contains(data, substring: StegoDefaults.DATA_SUFFIX) {
        break
      }
    }
  }
  
  /// Сбрасывает текущие параметры декодирования
  private func reset() {
    currentShift = StegoDefaults.INITIAL_SHIFT
    bitsCharacter = 0
  }
  
  /// Извлекает данные из пикселя
  /// - Parameter pixel: Пиксель, из которого извлекаются данные
  private func getDataFrom(pixel: UInt32) {
    getDataFrom(color: PixelUtilities.color(pixel, shift: PixelUtilities.colorToStep(step).rawValue))
  }
  
  /// Извлекает данные из цвета
  /// - Parameter color: Цвет, из которого извлекаются данные
  private func getDataFrom(color: UInt32) {
    let bit = color & 1
    bitsCharacter = (Int(bit) << currentShift) | bitsCharacter
    
    if currentShift == 0 {
      if step < StegoDefaults.sizeOfInfoLength() {
        length = PixelUtilities.addBits(
          length,
          UInt32(
            bitsCharacter
          ),
          shift: Int(
            step % UInt32(
              StegoDefaults.BITS_PER_COMPONENT - 1
            )
          )
        )
      } else {
        let character = String(UnicodeScalar(UInt8(bitsCharacter)))
        data.append(character)
      }
      bitsCharacter = 0
      currentShift = StegoDefaults.INITIAL_SHIFT
    } else {
      currentShift -= 1
    }
    step += 1
  }
  
  /// Проверяет, содержит ли декодированные данные
  /// - Returns: true, если данные содержатся, иначе false
  private func hasData() -> Bool {
    return !data.isEmpty && StegoUtilities.contains(
      data,
      substring: StegoDefaults.DATA_PREFIX
    ) && StegoUtilities.contains(
      data,
      substring: StegoDefaults.DATA_SUFFIX
    )
  }
}
