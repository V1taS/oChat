//
//  TorConnectScreenView.swift
//  MessengerSDK
//
//  Created by Vitalii Sosin on 07.06.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions
import Lottie

struct TorConnectScreenView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: TorConnectScreenPresenter
  
  // MARK: - Body
  
  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      VStack(spacing: .s4) {
        createTorConnectAnimation()
        
        Text("Connecting TOR ...")
          .font(.fancy.text.largeTitle)
          .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
        
        ProgressView(value: presenter.stateConnectionProgress, total: 1.0)
          .progressViewStyle(LinearProgressViewStyle(tint: SKStyleAsset.constantAzure.swiftUIColor))
          .background(Color.black.opacity(0.8))
          .cornerRadius(10)
        
        Text("Connecting to the Tor network \(String(Int(round(presenter.stateConnectionProgress))))%")
          .font(.fancy.text.regular)
          .foregroundColor(SKStyleAsset.constantSlate.swiftUIColor)
        
        Text("\(presenter.stateSystemMessage)")
          .font(.fancy.text.small)
          .foregroundColor(SKStyleAsset.constantAzure.swiftUIColor)
        
        RoundButtonView(style: .custom(text: "Reset")) {
          presenter.refreshTorConnectService()
        }
        
        Spacer()
      }
    }
    .padding(.horizontal, .s4)
  }
}

// MARK: - Private

private extension TorConnectScreenView {
  func createTorConnectAnimation() -> some View {
    VStack {
      Spacer()
      LottieView(
        animation: .asset(
          MessengerSDKAsset.circleNetworkLoaderLottie.name,
          bundle: MessengerSDKResources.bundle
        )
      )
      .resizable()
      .looping()
      .aspectRatio(contentMode: .fit)
      Spacer()
    }
  }
}

// MARK: - Preview

struct TorConnectScreenView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      TorConnectScreenAssembly().createModule(
        services: ApplicationServicesStub()
      ).viewController
    }
  }
}
