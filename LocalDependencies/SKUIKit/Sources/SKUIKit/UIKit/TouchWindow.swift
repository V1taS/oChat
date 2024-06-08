//
//  TouchWindow.swift
//  SKUIKit
//
//  Created by Vitalii Sosin on 11.05.2024.
//

import UIKit
import SKAbstractions

// MARK: - TouchWindow

/// Класс окна для обработки событий касания. Используется для отслеживания активности пользователя.
public final class TouchWindow: UIWindow, ITouchWindow {
  
  // MARK: - Public properties
  
  /// Обработчик событий, вызываемый при каждом касании.
  public var didSendEvent: ((_ event: UIEvent?) -> Void)?
  
  // MARK: - Public init
  
  /// Создает и отображает окно на весь экран, которое невидимо для пользователя и способно перехватывать события касания.
  public override init(windowScene: UIWindowScene?) {
    super.init(frame: UIScreen.main.bounds)
    self.windowScene = windowScene
    makeKeyAndVisible()
  }
  
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Public func
  
  /// Определяет, принимает ли окно событие касания в данной точке.
  /// - Returns: Всегда возвращает `false`, окно не реагирует на касания как обычный UI элемент.
  public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    didSendEvent?(event)
    return true
  }
}
