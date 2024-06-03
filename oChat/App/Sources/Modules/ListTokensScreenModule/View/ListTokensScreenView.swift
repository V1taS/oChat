//
//  ListTokensScreenView.swift
//  oChat
//
//  Created by Vitalii Sosin on 25.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI

struct ListTokensScreenView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: ListTokensScreenPresenter
  
  // MARK: - Body
  
  var body: some View {
    ScrollView(showsIndicators: false) {
      WidgetCryptoView(
        presenter.stateWidgetCryptoModels,
        searchText: $presenter.stateSearchText
      )
    }
    .searchable(text: $presenter.stateSearchText)
    .padding(.horizontal, .s4)
    .presentationDragIndicator(.hidden)
  }
}

// MARK: - Private

private extension ListTokensScreenView {}

// MARK: - Preview

struct ListTokensScreenView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      ListTokensScreenAssembly().createModule(
        screenType: .addTokenOnMainScreen(tokenModels: [.binanceMock])
      ).viewController
    }
  }
}
