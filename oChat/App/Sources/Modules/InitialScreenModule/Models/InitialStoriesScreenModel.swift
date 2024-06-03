//
//  InitialStoriesScreenModel.swift
//  oChat
//
//  Created by Vitalii Sosin on 13.01.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SKStoriesWidget
import SwiftUI
import SKStyle
import SKUIKit

enum InitialStoriesScreenModel: IStory {
  
  /// Заголовок для сторис
  var title: String {
    switch self {
    case .first:
      return OChatStrings.InitialScreenLocalization.Stories.Title.first
    case .second:
      return OChatStrings.InitialScreenLocalization.Stories.Title.second
    case .third:
      return OChatStrings.InitialScreenLocalization.Stories.Title.third
    case .fourth:
      return OChatStrings.InitialScreenLocalization.Stories.Title.fourth
    case .fifth:
      return OChatStrings.InitialScreenLocalization.Stories.Title.fifth
    }
  }
  
  /// Описание для сторис
  var subtitle: String {
    switch self {
    case .first:
      return OChatStrings.InitialScreenLocalization.Stories.Subtitle.first
    case .second:
      return OChatStrings.InitialScreenLocalization.Stories.Subtitle.second
    case .third:
      return OChatStrings.InitialScreenLocalization.Stories.Subtitle.third
    case .fourth:
      return OChatStrings.InitialScreenLocalization.Stories.Subtitle.fourth
    case .fifth:
      return OChatStrings.InitialScreenLocalization.Stories.Subtitle.fifth
    }
  }
  
  /// Продолжительность в секундах
  var duration: TimeInterval {
    return 10
  }

  /// Создаем сторис
  func builder(progress: Binding<CGFloat>) -> AnyView {
    AnyView(
      InitialStoriesScreenPage(
        progress: progress,
        title: title,
        subtitle: subtitle,
        storiesType: self
      )
    )
  }
  
  /// Первый сторис
  case first
  
  /// Второй сторис
  case second
  
  /// Третий сторис
  case third
  
  /// Четвертый сторис
  case fourth
  
  /// Пятый сторис
  case fifth
}
