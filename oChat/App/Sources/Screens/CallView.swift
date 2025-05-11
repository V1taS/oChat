//
//  CallView.swift
//  oChat
//
//  Created by Vitalii Sosin on 11.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import SwiftUI

// MARK: - Палитра
private enum Palette {
  static let gradient = LinearGradient(
    colors: [
      Color(red: 126/255, green: 92/255,  blue: 253/255),
      Color(red: 103/255, green: 76/255,  blue: 245/255),
      Color(red:  88/255, green: 62/255,  blue: 235/255)
    ],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
  )
  static let controlBG   = Color.white.opacity(0.16)
  static let controlFG   = Color.white.opacity(0.95)
  static let hangupBG    = Color.red
}

// MARK: - Экран звонка
struct CallView: View {

  // MARK: Public
  let avatar: Image = Image("playstore")
  let name: String = "Wife 👱‍♀️"
  let status: String = "Запрос…"

  // Callbacks
  var onSpeaker: () -> Void = {}
  var onVideo:   () -> Void = {}
  var onMute:    () -> Void = {}
  var onHangup:  () -> Void = {}
  var onBack:    () -> Void = {}

  @Environment(\.dismissWithoutAnimation) private var close

  // MARK: - Body
  var body: some View {
    ZStack {
      Palette.gradient
        .ignoresSafeArea()

      VStack(spacing: 48) {
        Spacer(minLength: 32)

        // Аватар
        avatar
          .resizable()
          .scaledToFill()
          .frame(width: 168, height: 168)
          .clipShape(Circle())
          .overlay(
            Circle()
              .strokeBorder(Color.white.opacity(0.4), lineWidth: 6)
              .shadow(radius: 8)
          )

        // Имя + статус
        VStack(spacing: 6) {
          Text(name)
            .font(.title)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
          Text(status)
            .font(.subheadline)
            .foregroundStyle(.white.opacity(0.8))
        }

        Spacer()

        // Нижняя панель
        HStack(spacing: 36) {
          ControlButton(icon: "speaker.wave.2.fill",
                        label: "динамик",
                        tap: onSpeaker)

          ControlButton(icon: "video.fill",
                        label: "видео",
                        tap: onVideo)

          ControlButton(icon: "mic.slash.fill",
                        label: "убрать звук",
                        tap: onMute)

          ControlButton(icon: "xmark",
                        label: "завершить",
                        tap: close,
                        bg: Palette.hangupBG)
        }
        .padding(.bottom, 40)
      }
    }
    .navigationBarBackButtonHidden()
  }
}

// MARK: - ControlButton
private struct ControlButton: View {
  let icon: String
  let label: String
  var tap: () -> Void
  var bg: Color = Palette.controlBG

  var body: some View {
    VStack(spacing: 8) {
      Button(action: tap) {
        Image(systemName: icon)
          .font(.title)
          .foregroundStyle(Palette.controlFG)
          .frame(width: 72, height: 72)
          .background(bg, in: Circle())
      }
      .buttonStyle(.plain)

      Text(label)
        .font(.footnote)
        .foregroundStyle(.white.opacity(0.9))
    }
  }
}

// MARK: - Preview
#Preview {
  CallView()
}
