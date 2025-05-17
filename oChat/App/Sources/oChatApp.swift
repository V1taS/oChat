//
//  oChatApp.swift
//  oChat
//
//  Created by Vitalii Sosin on 9.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import SwiftUI

@main
struct oChatApp: App {
  /// «Вклеиваем» класс делегата в приложение
  @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
  @StateObject private var toxManager = ToxManager.shared
  @Environment(\.scenePhase) private var scenePhase

  var body: some Scene {
    WindowGroup {
      ChatsView()
        .environmentObject(toxManager)
    }
    .onChange(of: scenePhase) { newPhase, _ in
      if newPhase == .background {
        Task { try? await toxManager.restart() }
      }
    }
  }
}
