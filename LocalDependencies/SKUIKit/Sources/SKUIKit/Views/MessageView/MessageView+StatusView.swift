//
//  MessageView+StatusView.swift
//  oChat
//
//  Created by Vitalii Sosin on 24.06.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SwiftUI
import SKStyle

struct SendingMessageView: View {
  @State private var isAnimating = false
  
  var body: some View {
    ZStack {
      Circle()
        .trim(from: 0, to: 0.8)
        .stroke(SKStyleAsset.constantNavy.swiftUIColor.opacity(0.5), lineWidth: 2)
        .frame(width: 17, height: 17)
        .rotationEffect(.degrees(isAnimating ? 360 : 0))
        .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
        .onAppear {
          isAnimating = true
        }
    }
  }
}

struct FailedMessageView: View {
  var body: some View {
    Image(systemName: "exclamationmark.circle")
      .resizable()
      .foregroundColor(SKStyleAsset.constantRuby.swiftUIColor)
      .frame(width: 17, height: 17)
  }
}

struct SentMessageView: View {
  @State private var showSecondCheckmark = false
  
  var body: some View {
    ZStack {
      Image(systemName: "checkmark")
        .resizable()
        .foregroundColor(SKStyleAsset.constantNavy.swiftUIColor.opacity(0.5))
        .frame(width: 15, height: 11)
        .offset(x: -3, y: 0)
      
      if showSecondCheckmark {
        Image(systemName: "checkmark")
          .resizable()
          .foregroundColor(SKStyleAsset.constantNavy.swiftUIColor.opacity(0.5))
          .frame(width: 15, height: 11)
          .offset(x: 3, y: 0)
      }
    }
    .frame(width: 17, height: 17)
    .onAppear {
      withAnimation(Animation.easeInOut(duration: 0.5).delay(0.5)) {
        showSecondCheckmark = true
      }
    }
  }
}
