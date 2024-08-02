//
//  IUIService.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 21.03.2024.
//

import SwiftUI

// MARK: - IUIService

/// Сервис для работы с UI в приложении
public protocol IUIService {
  /// Генерирует QR-код из переданной строки.
  /// - Parameters:
  ///   - string: Строка для кодирования в QR-код.
  ///   - iconIntoQR: Необязательное изображение, которое будет вставлено в центр QR-кода, например логотип. По умолчанию отсутствует.
  ///   - Image: Возвращает `Image?`, который представляет сгенерированный QR-код с возможным изображением в центре. Возвращает `nil`, если QR-код не удалось сгенерировать.
  func generateQRCode(
    from string: String,
    iconIntoQR: UIImage?,
    completion: ((UIImage?) -> Void)?
  )
  
  /// Генерирует QR-код из переданной строки.
  /// - Parameters:
  ///   - string: Строка для кодирования в QR-код.
  ///   - backgroundColor: Цвет фона QR-кода. По умолчанию прозрачный.
  ///   - foregroundColor: Цвет переднего плана QR-кода, обычно черный или темный цвет для читаемости. По умолчанию используется темно-синий цвет из палитры SKStyle.
  ///   - iconIntoQR: Необязательное изображение, которое будет вставлено в центр QR-кода, например логотип. По умолчанию отсутствует.
  ///   - iconSize: Размер вставляемого изображения (логотипа) внутри QR-кода. По умолчанию 100x100 пикселей.
  ///   - iconBackgroundColor: Фон под изображением
  ///   - Image: Возвращает `Image?`, который представляет сгенерированный QR-код с возможным изображением в центре. Возвращает `nil`, если QR-код не удалось сгенерировать.
  func generateQRCode(
    from string: String,
    backgroundColor: Color,
    foregroundColor: Color,
    iconIntoQR: UIImage?,
    iconSize: CGSize,
    iconBackgroundColor: Color?,
    completion: ((UIImage?) -> Void)?
  )
  
  /// Сохраняет выбранную тему в UserDefaults.
  /// - Parameter interfaceStyle: Цветовая схема, которая будет сохранена. Если значение `nil`, предпочтение темы удаляется.
  func saveColorScheme(_ interfaceStyle: UIUserInterfaceStyle?)
  
  /// Получает текущую тему приложения на основе сохраненных настроек.
  /// - Returns: Возвращает `UIUserInterfaceStyle?`, представляющую текущую тему приложения. Возвращает `nil`, если тема не была установлена.
  func getColorScheme() -> UIUserInterfaceStyle?
  
  /// Сохраняет изображение в галерее устройства.
  /// - Parameters:
  ///   - imageData: Данные изображения в формате `Data?`. Если передается `nil`, изображение не будет сохранено.
  ///   - return: `Bool`, указывающий успешно ли было сохранение изображения.
  @discardableResult
  func saveImageToGallery(_ imageData: Data?) async -> Bool
  
  /// Сохраняет видео в галерее устройства.
  /// - Parameters:
  ///   - video: Ссылка на видео
  ///   - return: `Bool`, указывающий успешно ли было сохранение видео.
  @discardableResult
  func saveVideoToGallery(_ video: URL?) async -> Bool
  
  /// Получение изображения по URL.
  /// - Parameters:
  ///   - url: URL изображения.
  ///   - completion: Замыкание, вызываемое с загруженным изображением или nil.
  func getImage(for url: URL?, completion: @escaping (UIImage?) -> Void)
}
