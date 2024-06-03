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
    VStack(spacing: .zero) {
      ScrollView(.vertical, showsIndicators: false) {
        VStack(spacing: .s6) {
          WidgetCryptoView(presenter.stateWidgetCryptoModels)
        }
        .padding(.horizontal, .s4)
        .padding(.top, .s3)
      }
    }
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
