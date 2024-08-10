//
//  IAppSettingsManager.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 18.05.2024.
//

import Foundation

/// Работа с настройками приложения
public protocol IAppSettingsDataManager {
  /// Получить модель настроек приложения
  /// - Returns: Асинхронная операция, возвращающая модель настроек `AppSettingsModel`
  func getAppSettingsModel() async -> AppSettingsModel
  
  /// Сохранить модель настроек приложения
  /// - Parameter model: Модель настроек `AppSettingsModel`, которую необходимо сохранить
  func saveAppSettingsModel(_ model: AppSettingsModel) async
  
  /// Удалить все данные настроек приложения
  /// - Returns: Возвращает `true`, если данные успешно удалены
  @discardableResult
  func deleteAllData() -> Bool
  
  /// Установить пароль для приложения
  /// - Parameter value: Пароль для приложения
  func setAppPassword(_ value: String?) async
  
  /// Установить фейковый пароль для приложения
  /// - Parameter value: Фейковый пароль для приложения
  func setFakeAppPassword(_ value: String?) async
  
  /// Установить тип доступа
  /// - Parameter accessType: Тип доступа, используемый в приложении
  func setAccessType(_ accessType: AppSettingsModel.AccessType) async
  
  /// Установить статус подписки на премиум
  /// - Parameter value: Булево значение, указывающее, включен ли премиум
  func setIsPremiumEnabled(_ value: Bool) async
  
  /// Установить статус индикатора набора текста
  /// - Parameter value: Булево значение, указывающее, включен ли индикатор набора текста
  func setIsTypingIndicatorEnabled(_ value: Bool) async
  
  /// Установить возможность сохранения медиафайлов
  /// - Parameter value: Булево значение, указывающее, можно ли сохранять медиафайлы
  func setCanSaveMedia(_ value: Bool) async
  
  /// Установить статус хранения истории чатов
  /// - Parameter value: Булево значение, указывающее, сохраняется ли история чатов
  func setIsChatHistoryStored(_ value: Bool) async
  
  /// Установить статус включения изменения голоса
  /// - Parameter value: Булево значение, указывающее, включено ли изменение голоса
  func setIsVoiceChangerEnabled(_ value: Bool) async
  
  /// Установить статус включения уведомлений
  /// - Parameter value: Булево значение, указывающее, включены ли уведомления
  func setIsEnabledNotifications(_ value: Bool) async
  
  /// Сохранить токен для push-уведомлений
  /// - Parameter token: Токен push-уведомлений
  func saveMyPushNotificationToken(_ token: String) async
  
  /// Сохранить состояние Tox в виде строки
  /// - Parameter toxStateAsString: Строковое представление состояния Tox
  func setToxStateAsString(_ toxStateAsString: String?) async
}
