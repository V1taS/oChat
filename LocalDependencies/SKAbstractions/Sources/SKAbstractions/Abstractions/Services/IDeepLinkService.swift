//
//  IDeepLinkService.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 06.06.2024.
//

import Foundation

/// Протокол для работы с глубокими ссылками (deep links).
public protocol IDeepLinkService {
  /// Сохраняет URL глубокой ссылки.
  /// - Parameters:
  ///   - url: URL, который необходимо сохранить.
  @MainActor
  func saveDeepLinkURL(_ url: URL) async
  
  /// Удаляет URL глубокой ссылки.
  func deleteDeepLinkURL()
  
  /// Получает адрес глубокой ссылки.
  /// - Parameter completion: Блок выполнения с адресом в виде строки или nil, если адрес не найден.
  @MainActor
  func getMessengerAddress() async -> String?
}
