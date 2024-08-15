//
//  SubscribeButtonView.swift
//  SKUIKit
//
//  Created by Vitalii Sosin on 15.08.2024.
//

import SwiftUI
import SKStyle

public struct SubscribeButtonView: View {
  
  // MARK: - Private properties
  
  @Binding var selectedPlan: Bool
  
  // MARK: - Initialization
  
  /// Инициализатор
  /// - Parameters:
  ///   - text: Текст, который будет отображаться рядом с чек боксом
  public init() {}
  
  // MARK: - Body
  
  public var body: some View {
    ZStack {
        HStack(spacing: 16) {
            if selectedPlan {
                Image.checkmarkCircleIcon
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.darkOrange)
            } else {
                Image.circleIcon
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.darkOrange)
            }
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("\(plan.rawValue) $" + String(format: "%.2f", plan.cost))
                        .font(.system(size: 20, weight: .semibold))
                    Text("($4.17/mo)")
                        .font(.system(size: 14, weight: .regular))
                    Spacer()
                }
                Text("7-day free trial")
                    .font(.system(size: 14, weight: .regular))
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .padding(.horizontal, 20)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(selectedPlan == plan ? Color.darkOrange : Color.clear, lineWidth: 4)
        )
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
        .padding(.horizontal, 20)
        
        VStack {
            HStack {
                Spacer()
                Text("Save 40%")
                    .font(.system(size: 14, weight: .medium))
                    .padding(8)
                    .background(Color.darkOrange)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .opacity(selectedPlan == plan ? 1 : 0)
            }.padding(.horizontal, 40).padding(.top, -12)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
    }
    .onTapGesture { selectedPlan = plan }
  }
}

// MARK: - Constants

private enum Constants {}

// MARK: - Preview

struct SubscribeButtonView_Previews: PreviewProvider {
  static var previews: some View {
    SubscribeButtonView()
      .background(SKStyleAsset.onyx.swiftUIColor)
      .ignoresSafeArea(.all)
  }
}
