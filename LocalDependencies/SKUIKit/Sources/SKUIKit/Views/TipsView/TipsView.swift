//
//  TipsView.swift
//
//
//  Created by Vitalii Sosin on 24.01.2024.
//

import SwiftUI
import SKStyle

public struct TipsView: View {
  
  // MARK: - Private properties
  
  private let model: TipsView.Model
  private let impactFeedback = UIImpactFeedbackGenerator(style: .soft)
  
  // MARK: - Initialization
  
  /// Инициализатор
  /// - Parameters:
  ///   - model: Модель данных
  public init(_ model: TipsView.Model) {
    self.model = model
  }
  
  // MARK: - Body
  
  public var body: some View {
    ZStack {
      TapGestureView(
        style: .flash,
        isSelectable: model.isSelectableTips,
        touchesEnded: {
          model.actionTips?()
        }
      ) {
        model.style.backgroundColor
      }
      
      HStack(alignment: .firstTextBaseline, spacing: .zero) {
        Text(model.text)
          .font(.fancy.text.regular)
          .foregroundColor(SKStyleAsset.constantOnyx.swiftUIColor)
          .lineLimit(.max)
          .allowsHitTesting(false)
          .padding(.leading, .s3)
          .padding(.vertical, .s3)
          .if(model.isCloseButton) { view in
            view
              .padding(.trailing, .s2)
          } else: { view in
            view
              .padding(.trailing, .s3)
          }
        
        if model.isCloseButton {
          Button(
            action: {
              model.closeButtonAction?()
              impactFeedback.impactOccurred()
            },
            label: {
              Image(systemName: "xmark")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(SKStyleAsset.constantOnyx.swiftUIColor)
                .frame(width: .s3, height: .s3)
                .padding(.trailing, .s3)
                .padding(.leading, .s2)
                .padding(.top, .s3)
            }
          )
        }
      }
    }
    .clipShape(RoundedRectangle(cornerRadius: .s5))
  }
}

// MARK: - Private

private extension TipsView {}

// MARK: - Constants

private enum Constants {}

// MARK: - Preview

struct TipsViewView_Previews: PreviewProvider {
  static var previews: some View {
    ZStack {
      VStack {
        HStack{
          Spacer()
        }
        Spacer()
        TipsView(
          .init(
            text: "Никогда не передавайте третьим лицам вашу фразу восстановления, храните ее в надежном месте!",
            style: .attention,
            isSelectableTips: true,
            actionTips: {},
            isCloseButton: true,
            closeButtonAction: {})
        )
        Spacer()
      }
    }
    .background(SKStyleAsset.onyx.swiftUIColor)
    .ignoresSafeArea(.all)
  }
}
