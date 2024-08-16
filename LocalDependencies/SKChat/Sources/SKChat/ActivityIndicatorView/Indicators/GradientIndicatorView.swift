//
//  GradientIndicatorView.swift
//  ActivityIndicatorView
//
//  Created by Sosin Vitalii on 09.03.2023.
//

import SwiftUI

struct GradientIndicatorView: View {
  
  let colors: [Color]
  let lineCap: CGLineCap
  let lineWidth: CGFloat
  
  @State private var rotation: Double = 0
  
  var body: some View {
    let gradientColors = Gradient(colors: colors)
    let conic = AngularGradient(gradient: gradientColors, center: .center, startAngle: .zero, endAngle: .degrees(360))
    
    let animation = Animation
      .linear(duration: 1.5)
      .repeatForever(autoreverses: false)
    
    return ZStack {
      Circle()
        .stroke(colors.first ?? .white, lineWidth: lineWidth)
      
      Circle()
        .trim(from: lineWidth / 500, to: 1 - lineWidth / 100)
        .stroke(conic, style: StrokeStyle(lineWidth: lineWidth, lineCap: lineCap))
        .rotationEffect(.degrees(rotation))
        .onAppear {
          rotation = 0
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            withAnimation(animation) {
              rotation = 360
            }
          }
        }
    }
  }
}
