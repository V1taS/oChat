//
//  JSONLoader.swift
//  oChat
//
//  Created by Vitalii Sosin on 9.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import Foundation

enum JSONLoader {

  /// Синхронная загрузка (удобно вызывать из `init`)
  static func load<T: Decodable>(
    _ type: T.Type,
    fromFile name: String,
    bundle: Bundle = .main,
    decoder: JSONDecoder = .init()
  ) throws -> T {
    guard let url = bundle.url(forResource: name, withExtension: "json") else {
      throw LoaderError.fileNotFound(name)
    }
    let data = try Data(contentsOf: url)
    return try decoder.decode(T.self, from: data)
  }

  /// Асинхронная версия (iOS 15+)
  static func loadAsync<T: Decodable>(
    _ type: T.Type,
    fromFile name: String,
    bundle: Bundle = .main,
    decoder: JSONDecoder = .init()
  ) async throws -> T {
    guard let url = bundle.url(forResource: name, withExtension: "json") else {
      throw LoaderError.fileNotFound(name)
    }
    let (data, _) = try await URLSession.shared.data(from: url)
    return try decoder.decode(T.self, from: data)
  }

  enum LoaderError: Error, LocalizedError {
    case fileNotFound(String)
    var errorDescription: String? {
      switch self {
      case .fileNotFound(let name):
        return "Не удалось найти файл \(name).json в бандле"
      }
    }
  }
}
