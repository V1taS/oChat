//
//  NetworkError.swift
//  
//
//  Created by Vitalii Sosin on 30.04.2022.
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
