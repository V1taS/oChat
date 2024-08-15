//
//  PremiumScreenView.swift
//  oChat
//
//  Created by Vitalii Sosin on 15.08.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions
import SKStoriesWidget

struct PremiumScreenView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: PremiumScreenPresenter
  
  // MARK: - Body
  
  var body: some View {
    VStack(spacing: .s4) {
      SKStoriesWidget(
        manager: StoriesManager.self,
        stories: PremiumStoriesScreenModel.allCases,
        isShowProgress: false
      )
    }
    .padding(.horizontal, .s4)
    .padding(.bottom, .s4)
  }
}

// MARK: - Private

private extension PremiumScreenView {}

// MARK: - Preview

struct PremiumScreenView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      PremiumScreenAssembly().createModule(
        ApplicationServicesStub()
      ).viewController
    }
  }
}
