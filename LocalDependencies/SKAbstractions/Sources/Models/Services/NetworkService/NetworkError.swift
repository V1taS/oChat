//
//  NetworkError.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 31.05.2024.
//

import Foundation

/// Сетевая ошибка
public enum NetworkError: Error {
  
  /// Подключение к Интернету отсутствует
  case noInternetConnection
  
  /// Неверный URL-запрос
  case invalidURLRequest
  
  /// Код ошибки HTTPS
  /// - Parameters:
  ///  - code: Код ошибки
  ///  - localizedDescription: Описание ошибки
  case unacceptedHTTPStatus(code: Int, localizedDescription: String?)
  
  /// Непредвиденный ответ сервера
  case unexpectedServerResponse
  
  /// Ошибка преобразования данных
  case mappingError
}
