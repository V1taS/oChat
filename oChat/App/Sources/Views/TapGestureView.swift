//
//  TapGestureView.swift
//  oChat
//
//  Created by Vitalii Sosin on 17.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import SwiftUI

// MARK: - Public TapGestureView

public struct TapGestureView<Content: View>: View {

  // MARK: Style

  public enum Style {
    /// Уменьшаем прозрачность во время нажатия
    case flash
    /// Лёгкий zoom‑out при нажатии
    case animationZoomOut
    /// Без визуального отклика
    case none

    /// Прозрачность, когда палец «нажат»
    var pressedOpacity: CGFloat { self == .flash ? 0.8 : 1.0 }
  }

  // MARK: Private props

  private let style: Style
  private let isSelectable: Bool
  private let isImpactFeedback: Bool
  private let touchesBegan: (() -> Void)?
  private let touchesEnded: () -> Void
  private let content: () -> Content

  private let impactFeedback = UIImpactFeedbackGenerator(style: .soft)

  // MARK: Init

  public init(
    style: Style = .flash,
    isSelectable: Bool = true,
    isImpactFeedback: Bool = true,
    touchesBegan: (() -> Void)? = nil,
    touchesEnded: @escaping () -> Void,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.style = style
    self.isSelectable = isSelectable
    self.isImpactFeedback = isImpactFeedback
    self.touchesBegan = touchesBegan
    self.touchesEnded = touchesEnded
    self.content = content
  }

  // MARK: Body

  public var body: some View {
    Group {
      if #available(iOS 18, *) {
        // ----- iOS 18 + -----
        InternalTap18(
          style: style,
          isSelectable: isSelectable,
          isImpactFeedback: isImpactFeedback,
          touchesBegan: touchesBegan,
          touchesEnded: touchesEnded,
          content: content
        )
      } else {
        // ----- iOS 17 -----
        Button(action: {
          if isImpactFeedback { impactFeedback.impactOccurred() }
          touchesEnded()
        }) {
          content()
        }
        .buttonStyle(
          TapGestureButtonStyle(
            style: style,
            touchesBegan: touchesBegan
          )
        )
        .disabled(!isSelectable)
      }
    }
  }
}

// MARK: - Реализация для iOS 18 -----------------------------------------------

@available(iOS 18, *)
private struct InternalTap18<Content: View>: View {

  let style: TapGestureView<Content>.Style
  let isSelectable: Bool
  let isImpactFeedback: Bool
  let touchesBegan: (() -> Void)?
  let touchesEnded: () -> Void
  let content: () -> Content

  @State private var isPressed = false
  private let impactFeedback = UIImpactFeedbackGenerator(style: .soft)

  var body: some View {
    let tap = TapGesture().onEnded { endTap() }

    let press = DragGesture(minimumDistance: 0)
      .onChanged { _ in startPress() }
      .onEnded { _ in reset(animated: true) }

    content()
      .contentShape(Rectangle())
      .opacity(isPressed ? style.pressedOpacity : 1)
      .scaleEffect(style == .animationZoomOut && isPressed ? 0.96 : 1)
      .animation(.easeInOut(duration: 0.2), value: isPressed)
      .allowsHitTesting(isSelectable)
      .highPriorityGesture(tap)
      .simultaneousGesture(press)
  }

  // MARK: Helpers

  private func startPress() {
    guard !isPressed else { return }
    isPressed = true
    touchesBegan?()
  }

  private func endTap() {
    if isImpactFeedback { impactFeedback.impactOccurred() }
    touchesEnded()
    reset(animated: true)
  }

  private func reset(animated: Bool) {
    let update = { isPressed = false }
    animated
    ? withAnimation(.easeInOut(duration: 0.2), update)
    : update()
  }
}

// MARK: - ButtonStyle для iOS 17

private struct TapGestureButtonStyle<Content: View>: ButtonStyle {

  let style: TapGestureView<Content>.Style
  let touchesBegan: (() -> Void)?

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .opacity(configuration.isPressed ? style.pressedOpacity : 1)
      .scaleEffect(style == .animationZoomOut && configuration.isPressed ? 0.96 : 1)
      .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
      .onChange(of: configuration.isPressed) { pressed, _ in
        if pressed { touchesBegan?() }
      }
  }
}
