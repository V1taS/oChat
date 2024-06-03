//
//  ListTokensScreenAbstractions.swift
//  oChat
//
//  Created by Vitalii Sosin on 25.04.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из `ListTokensScreenModule` в `Coordinator`
public protocol ListTokensScreenModuleOutput: AnyObject {
  /// Токен был выбран
  func tokenSelected(_ model: TokenModel)
  
  /// Токены были активированы
  func tokensIsActived(_ models: [TokenModel])
}

/// События которые отправляем из `Coordinator` в `ListTokensScreenModule`
public protocol ListTokensScreenModuleInput {

  /// События которые отправляем из `ListTokensScreenModule` в `Coordinator`
  var moduleOutput: ListTokensScreenModuleOutput? { get set }
}

/// Готовый модуль `ListTokensScreenModule`
public typealias ListTokensScreenModule = (viewController: UIViewController, input: ListTokensScreenModuleInput)

/// Делаем методы опциональными
extension ListTokensScreenModuleOutput {
  func tokenSelected(_ model: TokenModel) {}
  func tokensIsActived(_ models: [TokenModel]) {}
}
