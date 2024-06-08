//
//  TorServiceError.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 03.06.2024.
//

import Foundation

/// Ошибки, которые могут возникнуть при работе с Tor сервисом
public enum TorServiceError: Error {
  /// Не удалось загрузить адрес onion-сервиса
  case onionAddressForTorHiddenServiceCouldNotBeLoaded
  /// Ошибка при загрузке приватного ключа
  case errorLoadingPrivateKey
  /// Ошибка при удалении ключей
  case errorWhenDeletingKeys(_ errorTextDescription: String?)
  /// Произошла непредвиденная ошибка
  case somethingWentWrong(_ errorTextDescription: String?)
  /// Не удалось установить права доступа
  case failedToSetPermissions
  /// Ошибка при записи файла конфигурации torrc
  case failedToWriteTorrc(_ errorTextDescription: String?)
  /// Ошибка при создании директории
  case failedToCreateDirectory(_ errorTextDescription: String?)
  /// Директория авторизации уже была создана ранее
  case authDirectoryPreviouslyCreated
  /// Файл конфигурации torrc пуст
  case torrcFileIsEmpty
  /// Невозможно получить доступ к кэш-директории
  case unableToAccessTheCachesDirectory
}
