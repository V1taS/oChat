//
//  MessengerListScreenModuleView.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI

struct MessengerListScreenModuleView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: MessengerListScreenModulePresenter
  
  // MARK: - Body
  
  var body: some View {
    VStack(spacing: .zero) {
      ScrollView(.vertical, showsIndicators: false) {
        VStack(spacing: .zero) {
          ForEach(presenter.dialogWidgetModels, id: \.id) { widgetsModel in
            WidgetCryptoView(widgetsModel)
              .padding(.top, .s4)
          }
        }
        .padding(.horizontal, .s4)
        .padding(.bottom, .s4)
      }
    }
  }
}

// MARK: - Private

private extension MessengerListScreenModuleView {}

// MARK: - Preview

struct MessengerListScreenModuleView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      MessengerListScreenModuleAssembly(messengerDialogModels: []).createModule().viewController
    }
  }
}
