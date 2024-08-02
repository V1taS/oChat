//
//  AuthenticationScreenSuggestFaceIDModel.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 18.04.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import Foundation

// MARK: - AuthenticationScreenSuggestFaceIDModel

struct AuthenticationScreenSuggestFaceIDModel {
  /// Название лотти картинки для предложения подключить FaceID
  let imageName: String
  /// Заголовок для предложения подключить FaceID
  var title: String
  /// Название кнопки которая подключает FaceID
  var confirmButtonTitle: String
  /// Название кнопки которая пропускает подключение FaceID
  var skipButtonTitle: String
}
