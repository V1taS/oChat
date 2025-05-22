//
//  PersistenceManager.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import Combine
import SwiftUI
import ToxSwift

final class PersistenceManager: ObservableObject {
  @AppStorage("toxSavedata") private var savedataBase64: String = ""
  private let toxService: ToxServiceProtocol

  init(toxService: ToxServiceProtocol) {
    self.toxService = toxService
  }

  func persist() {
    Task.detached {
      let data = await self.toxService.exportSavedata()
      self.savedataBase64 = data.base64EncodedString()
    }
  }
}

// MARK: - Preview

extension PersistenceManager {
  /// Заглушка с демо-данными, чтобы превью работало офлайн
  static var preview: PersistenceManager {
    let toxService = try! ToxService()
    let persistenceManager = PersistenceManager(
      toxService: toxService
    )
    return persistenceManager
  }
}
