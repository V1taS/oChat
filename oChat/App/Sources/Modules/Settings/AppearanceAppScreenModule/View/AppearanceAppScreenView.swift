//
//  AppearanceAppScreenView.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions

struct AppearanceAppScreenView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: AppearanceAppScreenPresenter
  
  // MARK: - Body
  
  var body: some View {
    List {
      ForEach(Array(presenter.stateWidgetCryptoModels.enumerated()), id: \.element.id) { index, model in
        VStack(spacing: .zero) {
          WidgetCryptoView(model)
            .if(index == .zero) { view in
              view
                .clipShape(RoundedCornerShape(corners: [.topLeft, .topRight], radius: .s4))
            }
            .if(index == presenter.stateWidgetCryptoModels.count - 1) { view in
              view
                .clipShape(RoundedCornerShape(corners: [.bottomLeft, .bottomRight], radius: .s4))
            }
          
          if index < presenter.stateWidgetCryptoModels.count - 1 {
            Divider()
              .background(SKStyleAsset.constantSlate.swiftUIColor.opacity(0.3))
          }
        }
        .listRowBackground(Color.clear)
        .listRowInsets(.init(top: .zero, leading: .s4, bottom: .zero, trailing: .s4))
        .listRowSeparator(.hidden)
      }
    }
    .background(Color.clear)
    .listStyle(PlainListStyle())
    .listRowSeparator(.hidden)
  }
}

// MARK: - Private

private extension AppearanceAppScreenView {}

// MARK: - Preview

struct AppearanceAppScreenView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      AppearanceAppScreenAssembly().createModule(
        ApplicationServicesStub()
      ).viewController
    }
  }
}
