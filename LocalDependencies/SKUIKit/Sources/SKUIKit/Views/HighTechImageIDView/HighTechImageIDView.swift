//
//  HighTechImageIDView.swift
//
//
//  Created by Vitalii Sosin on 25.02.2024.
//

import SwiftUI
import SKStyle
import Lottie

public struct HighTechImageIDView: View {
  
  // MARK: - Private properties
  
  private let model: HighTechImageIDView.Model
  
  // MARK: - Initialization
  
  /// Инициализатор
  /// - Parameters:
  ///   - model: Модель данных
  public init(_ model: HighTechImageIDView.Model) {
    self.model = model
  }
  
  // MARK: - Body
  
  public var body: some View {
    VStack(spacing: .zero) {
      TapGestureView(
        style: .none,
        isSelectable: false,
        touchesEnded: { model.action?() }
      ) {
        createImageIDView()
      }
    }
  }
}

// MARK: - Private

private extension HighTechImageIDView {
  @ViewBuilder
  func createImageIDView() -> some View {
    ZStack {
      SKStyleAsset.navy.swiftUIColor
      
      createBackImage()
      createFrontImage()
    }
    .frame(width: UIScreen.main.bounds.width / 1.5, height: UIScreen.main.bounds.width / 1.2)
    .clipShape(RoundedRectangle(cornerRadius: .s5))
  }
  
  @ViewBuilder
  func createFrontImage() -> some View {
    VStack(spacing: .zero) {
      switch model.imageState {
      case .initial:
        VStack(spacing: .zero) {
          Spacer()
          
          LottieView(animation: .asset(Constants.loaderDocumentCircle, bundle: .module))
            .resizable()
            .looping()
            .aspectRatio(contentMode: .fit)
          
          Spacer()
        }
      case .uploadingImage:
        LottieView(animation: .asset(Constants.loaderScaner, bundle: .module))
          .resizable()
          .looping()
          .aspectRatio(contentMode: .fit)
      case .uploadedImage:
        EmptyView()
      }
    }
  }
  
  func createBackImage() -> some View {
    VStack(spacing: .zero) {
      switch model.imageState {
      case .initial:
        AnyView(
          VStack(spacing: .zero) {
            Spacer()
            
            Image(systemName: "photo.badge.plus.fill")
              .resizable()
              .foregroundColor(SKStyleAsset.constantAzure.swiftUIColor)
              .aspectRatio(contentMode: .fit)
              .frame(width: .s18, height: .s18)
            
            Spacer()
          }
        )
      case .uploadingImage:
        if let image = model.image {
          ZStack {
            image
              .resizable()
              .aspectRatio(contentMode: .fill)
            
            SKStyleAsset.navy.swiftUIColor.opacity(0.7)
          }
        }
      case .uploadedImage:
        if let image = model.image {
          image
            .resizable()
            .aspectRatio(contentMode: .fill)
        }
      }
    }
  }
}

// MARK: - Constants

private enum Constants {
  static let loaderDocumentCircle = "loader_circle"
  static let loaderScaner = "loader_scaner"
}

// MARK: - Preview

struct HighTechImageIDView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      Spacer()
      HighTechImageIDView(.init(
        image: nil,
        imageState: .uploadedImage,
        action: {}
      ))
      Spacer()
      HStack {
        Spacer()
      }
    }
    .background(SKStyleAsset.onyx.swiftUIColor)
    .ignoresSafeArea(.all)
  }
}
