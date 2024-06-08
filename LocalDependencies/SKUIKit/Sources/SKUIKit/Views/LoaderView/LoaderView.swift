//
//  LoaderView.swift
//
//
//  Created by Vitalii Sosin on 04.02.2024.
//

import SwiftUI
import SKStyle
import Lottie

public struct LoaderView: View {
  
  private let isBackground: Bool
  
  // MARK: - Initialization
  
  /// Инициализатор
  public init(isBackground: Bool = true) {
    self.isBackground = isBackground
  }
  
  // MARK: - Body
  
  public var body: some View {
    VStack {
      Spacer()
      LottieView(animation: .asset(Constants.loaderFlipCoinName, bundle: .module))
        .resizable()
        .looping()
        .aspectRatio(contentMode: .fit)
        .frame(width: 300, height: 300)
      Spacer()
      Spacer()
      HStack {
        Spacer()
      }
    }
    .if(isBackground, transform: { view in
      view
        .background(Material.ultraThin)
    })
  }
}

// MARK: - Private

private extension LoaderView {}

// MARK: - Constants

private enum Constants {
  static let loaderFlipCoinName = "loader_flip_coin"
}

// MARK: - Extension for View

public extension View {
  func loaderView(isOn: Bool) -> some View {
    modifier(LoaderViewModifier(isOn: isOn))
  }
}

struct LoaderViewModifier: ViewModifier {
  let isOn: Bool
  
  func body(content: Content) -> some View {
    ZStack {
      content
      if isOn {
        LoaderView()
      }
    }
  }
}

// MARK: - Preview

struct LoaderView_Previews: PreviewProvider {
  static var previews: some View {
    ZStack {
      VStack {
        HStack{
          Spacer()
        }
        Spacer()
        LoaderView()
        Spacer()
      }
    }
    .background(SKStyleAsset.onyx.swiftUIColor)
    .ignoresSafeArea(.all)
  }
}
