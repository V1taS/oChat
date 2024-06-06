//
//  InitialScreenView.swift
//  oChat
//
//  Created by Vitalii Sosin on 17.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKStoriesWidget
import SKAbstractions

struct InitialScreenView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: InitialScreenPresenter
  
  // MARK: - Body
  
  var body: some View {
    VStack(spacing: .s4) {
      SKStoriesWidget(
          manager: StoriesManager.self,
          stories: InitialStoriesScreenModel.allCases
      )
      
      Spacer()
      
      MainButtonView(
        text: presenter.stateNewWalletButtonTitle
      ) {
        presenter.moduleOutput?.newWalletButtonTapped()
      }
    }
    .padding(.horizontal, .s4)
    .padding(.bottom, .s4)
  }
}

// MARK: - Private

private extension InitialScreenView {}

// MARK: - Preview

struct InitialScreenView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      InitialScreenAssembly().createModule(ApplicationServicesStub()).viewController
    }
  }
}
