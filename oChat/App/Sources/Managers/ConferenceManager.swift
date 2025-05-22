//
//  ConferenceManager.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import Combine
import SwiftUI
import ToxSwift

final class ConferenceManager: ObservableObject {
  @Published var conferences: [ConferenceModel] = []
  private let toxService: ToxServiceProtocol

  init(toxService: ToxServiceProtocol) { self.toxService = toxService }

  func refresh() async {
    let confIDs = await toxService.conferenceList()
    var updatedConfs: [ConferenceModel] = []

    for cid in confIDs {
      let title = await toxService.getConferenceTitle(cid)
      let type = await toxService.getConferenceType(cid)

      let model = ConferenceModel(
        id: cid,
        title: title,
        type: type
      )
      updatedConfs.append(model)
    }
    conferences = updatedConfs
  }

  func handleConferenceEvent(_ event: ConferenceEvent) {
    if case let .connected(id) = event { Task { await refresh() } }
  }
}

// MARK: - Preview

extension ConferenceManager {
  /// Заглушка с демо-данными, чтобы превью работало офлайн
  static var preview: ConferenceManager {
    let toxService = try! ToxService()
    let conferenceManager = ConferenceManager(
      toxService: toxService
    )
    return conferenceManager
  }
}
