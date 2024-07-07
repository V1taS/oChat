//
//  ProgressView.swift
//  SKUIKit
//
//  Created by Vitalii Sosin on 23.06.2024.
//

import SwiftUI
import SKStyle

/// Представление для отображения прогресса с градиентным заполнением.
public struct ProgressGradientView: View {
  
  /// Прогресс, отображаемый в виде процентов.
  @Binding private var progress: CGFloat
  
  /// Инициализатор, принимающий прогресс в виде биндинга.
  /// - Parameter progress: Биндинг значения прогресса от 0 до 1.
  public init(progress: Binding<CGFloat>) {
    self._progress = progress
  }
  
  public var body: some View {
    GeometryReader { geometry in
      let size = min(geometry.size.width, geometry.size.height)
      let lineWidth = size * 0.1
      let outerCircleDiameter = size
      let innerCircleDiameter = size * 0.8
      let imageHeight = size * 0.6
      let clampedMinProgress = min(max(progress, 0.1001), 0.9)
      
      VStack {
        ZStack {
          // Фон круга
          Circle()
            .stroke(Constants.progressBackgroundLinear, lineWidth: lineWidth)
            .frame(width: outerCircleDiameter, height: outerCircleDiameter)
          
          // Внутренний круг с цветом, изменяющимся в зависимости от прогресса
          Circle()
            .foregroundColor(
              clampedMinProgress == 0.9 ?
              SKStyleAsset.constantLime.swiftUIColor.opacity(0.5) :
                SKStyleAsset.constantRuby.swiftUIColor.opacity(0.5)
            )
            .frame(width: innerCircleDiameter, height: innerCircleDiameter)
            .overlay {
              Image(
                uiImage: UIImage(
                  named: SKStyleAsset.oChatInProgress.name,
                  in: SKStyleResources.bundle,
                  with: nil
                ) ?? UIImage()
              )
              .resizable()
              .renderingMode(.template)
              .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
              .aspectRatio(contentMode: .fit)
              .opacity(0.3)
              .frame(height: imageHeight)
            }
          
          // Метки для отображения прогресса
          ForEach(Array(stride(from: 0, through: 10, by: 1)), id: \.self) { i in
            Text("\(i * 10)")
              .font(.fancy.text.small)
              .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
              .rotationEffect(.degrees(-120 - Double(i * 30)))
              .offset(x: outerCircleDiameter * 0.32)
              .rotationEffect(.degrees(Double(i * 30)))
          }
          .rotationEffect(.degrees(120))
          
          // Круг с градиентным заполнением
          Circle()
            .trim(from: 0.1, to: clampedMinProgress)
            .stroke(Constants.progressLinear, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            .frame(width: outerCircleDiameter, height: outerCircleDiameter)
            .rotationEffect(.degrees(90))
        }
        .frame(width: geometry.size.width, height: geometry.size.height)
      }
    }
  }
}


// MARK: - Constants

private enum Constants {
  static let progressBackgroundLinear = LinearGradient(
    gradient: Gradient(
      colors: [
        SKStyleAsset.constantNavy.swiftUIColor,
        SKStyleAsset.constantNavy.swiftUIColor.opacity(0.01)
      ]
    ),
    startPoint: .top, endPoint: .bottom
  )
  
  static let progressLinear = LinearGradient(
    gradient: Gradient(
      colors: [
        SKStyleAsset.constantLime.swiftUIColor,
        SKStyleAsset.constantLime.swiftUIColor.opacity(0.03)
      ]
    ),
    startPoint: .leading, endPoint: .trailing
  )
}
