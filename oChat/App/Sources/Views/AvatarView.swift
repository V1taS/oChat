//
//  AvatarView.swift
//  oChat
//
//  Created by Vitalii Sosin on 10.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import SwiftUI

public struct AvatarView: View {
  let emoji: String?
  let address: String
  let isOnline: Bool

  public init(emoji: String?, address: String, isOnline: Bool) {
    self.emoji = emoji; self.address = address; self.isOnline = isOnline
  }

  public var body: some View {
    ZStack(alignment: .bottomTrailing) {
      Circle()
        .fill(bg)
        .frame(width: 44, height: 44)
        .overlay { Text(emoji ?? "?").font(.title2) }

      if isOnline {
        Circle().fill(.green)
          .frame(width: 10, height: 10)
          .offset(x: 2, y: 2)
      }
    }
    .accessibilityHidden(true)
  }

  private var bg: Color {
    let palette: [Color] = [.teal, .indigo, .blue, .cyan, .mint, .green]
    guard let byte = address.utf8.first else { return .gray.opacity(0.3) }
    return palette[Int(byte) % palette.count].opacity(0.25)
  }
}
