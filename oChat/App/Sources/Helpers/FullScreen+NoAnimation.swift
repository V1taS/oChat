//
//  FullScreen+NoAnimation.swift
//  oChat
//
//  Created by Vitalii Sosin on 11.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import SwiftUI

// MARK: - Публичный API
extension View {
  /// Мгновенно открывает `content` во весь экран.
  func presentFullScreenWithoutAnimation<Content: View>(
    @ViewBuilder _ content: @escaping () -> Content
  ) {
    FullScreenManager.shared.present(content())
  }

  /// Закрывает ранее открытый без анимации full-screen.
  func dismissFullScreenWithoutAnimation() {
    FullScreenManager.shared.dismiss()
  }
}

// MARK: - EnvironmentKey, чтобы внутри вью можно было писать @Environment(\.dismissWithoutAnimation)
private struct DismissWithoutAnimationKey: EnvironmentKey {
  static let defaultValue: () -> Void = { FullScreenManager.shared.dismiss() }
}

extension EnvironmentValues {
  var dismissWithoutAnimation: () -> Void {
    get { self[DismissWithoutAnimationKey.self] }
    set { self[DismissWithoutAnimationKey.self] = newValue }
  }
}

// MARK: - Сервис-одиночка
private final class FullScreenManager {
  static let shared = FullScreenManager()
  private init() {}

  private weak var host: UIHostingController<AnyView>?

  // Открыть
  func present<Content: View>(_ view: Content) {
    guard
      let scene  = UIApplication.shared.connectedScenes.first as? UIWindowScene,
      let window = scene.windows.first,
      let root   = window.rootViewController
    else { return }

    // Передаём dismiss в Environment, чтобы внутри вью был доступ
    let wrapped = view
      .environment(\.dismissWithoutAnimation) { [weak self] in self?.dismiss() }

    let host = UIHostingController(rootView: AnyView(wrapped))
    host.modalPresentationStyle = .fullScreen
    root.present(host, animated: false)

    self.host = host
  }

  // Закрыть
  func dismiss() {
    host?.presentingViewController?.dismiss(animated: false)
    host = nil
  }
}
