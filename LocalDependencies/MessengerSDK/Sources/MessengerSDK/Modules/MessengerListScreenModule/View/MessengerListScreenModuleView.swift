//
//  MessengerListScreenModuleView.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions
import Lottie

struct MessengerListScreenModuleView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: MessengerListScreenModulePresenter
  
  // MARK: - Body
  
  var body: some View {
    VStack(spacing: .zero) {
      if presenter.stateWidgetModels.isEmpty {
        createEmptyState()
      } else {
        createContent()
      }
    }
  }
}

// MARK: - Private

private extension MessengerListScreenModuleView {
  func createContent() -> some View {
    ScrollView(.vertical, showsIndicators: false) {
      VStack(spacing: .zero) {
        ForEach(presenter.stateWidgetModels, id: \.id) { widgetsModel in
          WidgetCryptoView(widgetsModel)
            .padding(.top, .s4)
        }
      }
      .padding(.horizontal, .s4)
      .padding(.bottom, .s4)
    }
  }
  
  func createEmptyState() -> some View {
    ScrollView(.vertical, showsIndicators: false) {
      VStack {
        Spacer()
        
        LottieView(
          animation: .asset(
            MessengerSDKAsset.emptyStateLottie.name,
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
}

// MARK: - Preview

struct MessengerListScreenModuleView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      MessengerListScreenModuleAssembly().createModule(
        services: ApplicationServicesStub()
      ).viewController
    }
  }
}
