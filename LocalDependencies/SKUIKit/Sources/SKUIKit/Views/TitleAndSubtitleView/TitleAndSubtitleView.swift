//
//  TitleAndSubtitleView.swift
//
//
//  Created by Vitalii Sosin on 10.12.2023.
//

import SwiftUI
import SKStyle

public struct TitleAndSubtitleView: View {
  
  // MARK: - Private properties
  
  private let title: TitleAndSubtitleView.Model?
  private let description: TitleAndSubtitleView.Model?
  private let alignment: HorizontalAlignment
  private let style: TitleAndSubtitleView.Style
  
  // MARK: - Initialization
  
  /// Инициализатор
  /// - Parameters:
  ///   - title: Заголовок
  ///   - description: Описание
  ///   - alignment: Выравнивание всего контента
  ///   - style: Стиль
  public init(
    title: TitleAndSubtitleView.Model? = nil,
    description: TitleAndSubtitleView.Model? = nil,
    alignment: HorizontalAlignment = .center,
    style: TitleAndSubtitleView.Style = .large
  ) {
    self.title = title
    self.description = description
    self.alignment = alignment
    self.style = style
  }
  
  // MARK: - Body
  
  public var body: some View {
    VStack(alignment: alignment, spacing: .zero) {
      if let title {
        // Заголовок
        TapGestureView(
          style: .animationZoomOut,
          isSelectable: title.isSelectable,
          touchesEnded: { title.action?() }
        ) {
          getTitleView(
            with: title.isSecure,
            text: title.text,
            lineLimit: title.lineLimit
          )
        }
      }
      
      if let description {
        // Описание
        TapGestureView(
          style: .animationZoomOut,
          isSelectable: description.isSelectable,
          touchesEnded: { description.action?() }
        ) {
          Text(description.isSecure ? Constants.secureText : description.text)
            .font(style.fontDescription)
            .foregroundColor(SKStyleAsset.constantSlate.swiftUIColor)
            .lineLimit(description.lineLimit)
            .truncationMode(.middle)
            .multilineTextAlignment(.center)
        }
        .padding(.top, .s2)
      }
    }
  }
}

// MARK: - Private

private extension TitleAndSubtitleView {
  func getTitleView(with isSecure: Bool, text: String, lineLimit: Int) -> AnyView {
    if isSecure {
      return AnyView(
        Image(systemName: "lock.circle")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: .s11, height: .s11)
          .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
      )
    } else {
      return AnyView(
        Text(isSecure ? Constants.secureText : text)
          .font(style.fontTitle)
          .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
          .lineLimit(lineLimit)
          .truncationMode(.tail)
          .multilineTextAlignment(.center)
      )
    }
  }
}

// MARK: - Constants

private enum Constants {
  static let secureText = "* * *"
}

// MARK: - Preview

struct TitleAndSubtitleView_Previews: PreviewProvider {
  static var previews: some View {
    ZStack {
      VStack {
        HStack{
          Spacer()
        }
        Spacer()
        TitleAndSubtitleView(
          title: .init(
            text: "$ 153,04",
            lineLimit: 1,
            isSelectable: true,
            isSecure: true,
            action: {}
          ),
          description: .init(
            text: "UQApvTCMascwAmF_LVtNJeEIUzZUOGR_h66t8FilkNf",
            lineLimit: 1,
            isSelectable: true,
            isSecure: false,
            action: {}),
          alignment: .center,
          style: .large
        )
        Spacer()
      }
    }
    .background(SKStyleAsset.onyx.swiftUIColor)
    .ignoresSafeArea(.all)
  }
}
