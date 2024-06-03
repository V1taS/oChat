//
//  ListNetworksScreenView.swift
//  oChat
//
//  Created by Vitalii Sosin on 26.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI

struct ListNetworksScreenView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: ListNetworksScreenPresenter
  
  // MARK: - Body
  
  var body: some View {
    ScrollView(showsIndicators: false) {
      WidgetCryptoView(
        presenter.stateWidgetModels,
        searchText: $presenter.stateSearchText
      )
    }
    .searchable(text: $presenter.stateSearchText)
    .padding(.horizontal, .s4)
    .presentationDragIndicator(.hidden)
  }
}

// MARK: - Private

private extension ListNetworksScreenView {}

// MARK: - Preview

struct ListNetworksScreenView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      ListNetworksScreenAssembly().createModule(.binanceMock).viewController
    }
  }
}
