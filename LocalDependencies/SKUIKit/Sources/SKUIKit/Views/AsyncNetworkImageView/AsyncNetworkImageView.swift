//
//  AsyncNetworkImageView.swift
//  SKUIKit
//
//  Created by Vitalii Sosin on 17.05.2024.
//

import SwiftUI
import SKStyle
import SKFoundation

public struct AsyncNetworkImageView: View {
  
  // MARK: - Private properties
  
  private let model: AsyncNetworkImageView.Model
  @State private var image: UIImage?
  @State private var imageLoadState: ImageLoadState = .loading
  
  
  // MARK: - Initialization
  
  /// Инициализатор
  /// - Parameters:
  ///   - imageUrl: Ссылка на изображение
  public init(_ model: AsyncNetworkImageView.Model) {
    self.model = model
  }
  
  // MARK: - Body
  
  public var body: some View {
    VStack {
      switch imageLoadState {
      case .loading:
        getLoadingView()
      case .success:
        getImageView(image)
      case .failure:
        getFailureView()
      }
    }
    .onAppear {
      ImageCacheService.shared.getImage(for: model.imageUrl) { image in
        if let image {
          self.image = image
          self.imageLoadState = .success
        } else {
          self.imageLoadState = .failure
        }
      }
    }
  }
}

// MARK: - Private

private extension AsyncNetworkImageView {
  func getFailureView() -> AnyView {
    return AnyView(EmptyView())
  }
  
  func getLoadingView() -> AnyView {
    return AnyView(
      ZStack {
        SKStyleAsset.constantSlate.swiftUIColor.opacity(0.1)
        ProgressView()
      }
        .frame(width: model.size.width, height: model.size.height)
        .cornerRadius(model.cornerRadiusType.cornerRadius(for: model.size))
    )
  }
  
  func getImageView(_ image: UIImage?) -> AnyView {
    guard let image else {
      return AnyView(EmptyView())
    }
    return AnyView(
      Image(uiImage: image)
        .resizable()
        .frame(width: model.size.width, height: model.size.height)
        .aspectRatio(contentMode: .fit)
        .cornerRadius(model.cornerRadiusType.cornerRadius(for: model.size))
    )
  }
}

// MARK: - Constants

private enum Constants {}

// MARK: - Preview

struct AsyncNetworkImageView_Previews: PreviewProvider {
  static var previews: some View {
    ZStack {
      VStack {
        HStack{
          Spacer()
        }
        Spacer()
        AsyncNetworkImageView(
          .init(
            imageUrl: URL(string: "https://safekeeper.sosinvitalii.com/safe_keeper/cryptoCurrency128/act.png"),
            size: .init(width: CGFloat.s15, height: .s15),
            cornerRadiusType: .squircle
          )
        )
        Spacer()
      }
    }
    .background(SKStyleAsset.onyx.swiftUIColor)
    .ignoresSafeArea(.all)
  }
}
