//
//  MessengerDialogHintModel.swift
//  MessengerSDK
//
//  Created by Vitalii Sosin on 17.06.2024.
//

import Foundation

struct MessengerDialogHintModel: Equatable {
  /// Название Лотти анимации
  let lottieAnimationName: String?
  /// Заголовок
  let headerTitle: String
  /// Описание
  let headerDescription: String
  /// Название кнопки
  let buttonTitle: String
  
  /// Первый заголовок
  let oneTitle: String
  /// Первое описание
  let oneDescription: String
  /// Название системного изображения
  let oneSystemImageName: String
  
  /// Второй заголовок
  let twoTitle: String
  /// Второй описание
  let twoDescription: String
  /// Название системного изображения
  let twoSystemImageName: String
  
  /// Третий заголовок
  let threeTitle: String
  /// Третее описание
  let threeDescription: String
  /// Название системного изображения
  let threeSystemImageName: String
}
