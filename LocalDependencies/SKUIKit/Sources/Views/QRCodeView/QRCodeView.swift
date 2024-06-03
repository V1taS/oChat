//
//  QRCodeView.swift
//
//
//  Created by Vitalii Sosin on 10.12.2023.
//

import SwiftUI
import SKStyle
import CoreImage.CIFilterBuiltins

public struct QRCodeView: View {
  
  // MARK: - Private properties
  
  private let qrCodeImage: Image?
  private let dataString: String
  
  // MARK: - Initialization
  
  /// Инициализатор
  /// - Parameters:
  ///   - qrCodeImage: Изображение  QR
  ///   - dataString: Например адрес кошелька
  public init(qrCodeImage: Image?,
              dataString: String) {
    self.qrCodeImage = qrCodeImage
    self.dataString = dataString
  }
  
  // MARK: - Body
  
  public var body: some View {
    VStack(spacing: .zero) {
      createQRCodeImage()
        .transition(.opacity)
        .animation(.default, value: qrCodeImage)
      
      Text(dataString)
        .font(.fancy.text.title)
        .foregroundColor(SKStyleAsset.constantNavy.swiftUIColor)
        .lineLimit(.max)
        .truncationMode(.tail)
        .allowsHitTesting(false)
        .padding(.horizontal, .s5)
        .multilineTextAlignment(.center)
        .padding(.bottom, .s5)
    }
    .background(SKStyleAsset.constantGhost.swiftUIColor)
    .clipShape(RoundedRectangle(cornerRadius: .s5))
  }
}

// MARK: - Private

private extension QRCodeView {
  func createQRCodeImage() -> some View {
    if let qrCodeImage = qrCodeImage {
      return AnyView(
        qrCodeImage
          .interpolation(.none)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .padding(.horizontal, .s5)
          .padding(.top, .s5)
          .padding(.bottom, .s1)
      )
    } else {
      return AnyView(
        SKStyleAsset.constantGhost.swiftUIColor
          .aspectRatio(contentMode: .fit)
          .padding(.horizontal, .s5)
          .padding(.top, .s5)
          .padding(.bottom, .s1)
          .overlay {
            ProgressView()
          }
      )
    }
  }
}

// MARK: - Preview

struct QRCodeView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      Spacer()
      QRCodeView(
        qrCodeImage: nil,
        dataString: "dfgsg"
      )
      Spacer()
    }
    .background(SKStyleAsset.onyx.swiftUIColor)
    .ignoresSafeArea(.all)
  }
}
