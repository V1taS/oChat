//
//  HeadersType.swift
//  
//
//  Created by Vitalii Sosin on 26.11.2022.
//

import Foundation

/// Тип хедера
public enum HeadersType {
  
  /// Хедоры
  var headers: [String: String] {
    let appearance = Appearance()
    switch self {
    case .acceptJson:
      return [appearance.headerFieldValue: appearance.headerFieldAccept]
    case .contentTypeJson:
      return [appearance.headerFieldValue: appearance.headerFieldContentType]
    case .acceptCustom(let value):
      return [value: appearance.headerFieldAccept]
    case .contentTypeCustom(let value):
      return [value: appearance.headerFieldContentType]
    case .additionalHeaders(let value):
      return value.reduce(into: [String: String]()) { result, tuple in
        result.updateValue(tuple.key, forKey: tuple.value)
      }
    }
  }
  
  /// Accept `JSON`
  case acceptJson
  
  /// Content-Type `JSON`
  case contentTypeJson
  
  /// Accept `Custom`
  case acceptCustom(setValue: String)
  
  /// Content-Type `Custom`
  case contentTypeCustom(setValue: String)
  
  /// Дополнительные заголовки
  case additionalHeaders(set: [(key: String, value: String)])
}

// MARK: - Appearance

private extension HeadersType {
  struct Appearance {
    let headerFieldAccept = "Accept"
    let headerFieldContentType = "Content-Type"
    let headerFieldValue = "application/json"
  }
}
