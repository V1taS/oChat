//
//  NotificationsSettingsScreenView.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions

struct NotificationsSettingsScreenView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: NotificationsSettingsScreenPresenter
  
  // MARK: - Body
  
  var body: some View {
    List {
      ForEach(Array(presenter.stateWidgetCryptoModels.enumerated()), id: \.element.id) { index, model in
        VStack(spacing: .zero) {
          WidgetCryptoView(model)
            .if(index == 0) { view in
              view
                .clipShape(RoundedCornerShape(corners: [.topLeft, .topRight], radius: .s4))
            }
            .if(index == presenter.stateWidgetCryptoModels.count - 1) { view in
              view
                .clipShape(RoundedCornerShape(corners: [.bottomLeft, .bottomRight], radius: .s4))
            }
          
          if index < presenter.stateWidgetCryptoModels.count - 1 {
            Divider()
              .background(SKStyleAsset.slate.swiftUIColor.opacity(0.3))
          }
        }
        .listRowBackground(Color.clear)
        .listRowInsets(.init(top: .zero, leading: .s4, bottom: .zero, trailing: .s4))
        .listRowSeparator(.hidden)
      }
    }
    .background(Color.clear)
    .listStyle(PlainListStyle())
    .padding(.vertical, .s4)
  }
}

// MARK: - Private

private extension NotificationsSettingsScreenView {}

// MARK: - Preview

struct NotificationsSettingsScreenView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      NotificationsSettingsScreenAssembly().createModule(
        ApplicationServicesStub()
      ).viewController
    }
  }
}
