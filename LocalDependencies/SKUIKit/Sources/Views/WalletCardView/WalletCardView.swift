//
//  WalletCardView.swift
//  SKUIKit
//
//  Created by Vitalii Sosin on 09.05.2024.
//

import SwiftUI
import SKStyle

public struct WalletCardView: View {
  
  // MARK: - Private properties
  
  @State private var valueTranslation : CGSize = .zero
  @State private var isDragging = false
  private let model: WalletCardView.Model
  
  // MARK: - Initialization
  
  public init(_ model: WalletCardView.Model) {
    self.model = model
  }
  
  // MARK: - Body
  
  public var body: some View {
    ZStack {
      Rectangle()
        .fill(
          LinearGradient(
            gradient: Gradient(
              colors: model.walletStyle.cardGradientColors
            ),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
        )
      
        .overlay(
          Rectangle()
            .fill(Material.ultraThin)
            .frame(width: 339, height: 214)
            .cornerRadius(10)
        )
        .overlay(
          Rectangle()
            .frame(width: 320, height: 40)
            .colorInvert()
            .blur(radius: 70)
            .offset(x: -valueTranslation.width / 2, y: -valueTranslation.height / 2)
        )
        .clipped()
      
      VStack(alignment: .leading) {
        HStack {
          VStack(alignment: .leading, spacing: .s1) {
            Text(model.walletName.formatString(minTextLength: 20))
              .foregroundColor(model.walletStyle.walletNameColor)
              .font(.fancy.text.title)
            
            Text(model.walletAddress.formatString(minTextLength: 20))
              .foregroundColor(model.walletStyle.walletAddressColor)
              .font(.fancy.text.regular)
          }
          Spacer()
        }
        Spacer()
        
        Text("\(model.totalAmount) \(model.currency)")
          .foregroundColor(model.walletStyle.walletTotalAmountColor)
          .font(.fancy.text.largeTitle)
          .fontWeight(.bold)
          .lineLimit(2)
        Spacer()
        Spacer()
        Spacer()
        Spacer()
      }
      .padding(.s4)
    }
    .overlay(content: {
      HStack {
        Spacer()
        SKUIKitAsset.skWatermark.swiftUIImage
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(height: 100)
          .blendMode(.destinationOut)
          .padding(.s4)
      }
    })
    .frame(width: 339, height: 214)
    .cornerRadius(10)
    .rotation3DEffect(
      .degrees(isDragging ? calculateRotation(valueTranslation) : 0),
      axis: (x: 0, y: 1, z: 0)
    )
    .gesture(DragGesture()
      .onChanged({ value in
        withAnimation {
          valueTranslation = CGSize(width: value.translation.width, height: value.translation.height)
          isDragging = true
        }
      })
        .onEnded({ value in
          withAnimation {
            valueTranslation = .zero
            isDragging = false
          }
        })
    )
  }
  
  private func calculateRotation(_ translation: CGSize) -> CGFloat {
    let horizontalRotation = min(5, abs(translation.width / 339 * 5))
    return translation.width > 0 ? horizontalRotation : -horizontalRotation
  }
}


// MARK: - Constants

private enum Constants {}

// MARK: - Preview

struct WalletCardView_Previews: PreviewProvider {
  static var previews: some View {
    ZStack {
      HStack {
        SKStyleAsset.onyx.swiftUIColor
      }
      
      VStack {
        Spacer()
        WalletCardView(
          .init(
            walletName: "Wallet - 1",
            walletAddress: "ewfnwkjfnewjkfnhjkwebfjhkqebgfkjhqwbefhjbqwkfj",
            totalAmount: "1 000 000",
            currency: "$",
            walletStyle: .standard
          )
        )
        Spacer()
      }
    }
    .background(SKStyleAsset.onyx.swiftUIColor)
    .ignoresSafeArea(.all)
  }
}
