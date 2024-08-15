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
        stories: InitialStoriesScreenModel.allCases, 
        isShowProgress: true
      )
      
      Spacer()
      
      MainButtonView(
        text: OChatStrings.InitialScreenLocalization.Stories.Button.Demo.title,
        style: .secondary
      ) {
        Task {
          await presenter.continueButtonTapped(.demo)
        }
      }
      MainButtonView(
        text: OChatStrings.InitialScreenLocalization.Stories.Button.Start.title
      ) {
        Task {
          await presenter.continueButtonTapped(.main)
        }
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
