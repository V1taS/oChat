//
//  PasscodeSettingsScreenView.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions

struct PasscodeSettingsScreenView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: PasscodeSettingsScreenPresenter
  
  // MARK: - Body
  
  var body: some View {
    List {
      Section {
        ForEach(Array(presenter.statePasswordWidgetModels.enumerated()), id: \.element.id) { index, model in
          VStack(spacing: .zero) {
            WidgetCryptoView(model)
              .if(index == .zero) { view in
                view
                  .clipShape(RoundedCornerShape(corners: [.topLeft, .topRight], radius: .s4))
              }
              .if(index == presenter.statePasswordWidgetModels.count - 1) { view in
                view
                  .clipShape(RoundedCornerShape(corners: [.bottomLeft, .bottomRight], radius: .s4))
              }
            
            if index < presenter.statePasswordWidgetModels.count - 1 {
              Divider()
                .background(SKStyleAsset.constantSlate.swiftUIColor.opacity(0.3))
            }
          }
          .listRowBackground(Color.clear)
          .listRowInsets(.init(top: .zero, leading: .s4, bottom: .zero, trailing: .s4))
          .listRowSeparator(.hidden)
        }
      }
      
      Spacer()
        .frame(height: .s1)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
      
      Section {
        ForEach(Array(presenter.stateSecurityWidgetModels.enumerated()), id: \.element.id) { index, model in
          VStack(spacing: .zero) {
            WidgetCryptoView(model)
              .if(index == .zero) { view in
                view
                  .clipShape(RoundedCornerShape(corners: [.topLeft, .topRight], radius: .s4))
              }
              .if(index == presenter.stateSecurityWidgetModels.count - 1) { view in
                view
                  .clipShape(RoundedCornerShape(corners: [.bottomLeft, .bottomRight], radius: .s4))
              }
            
            if index < presenter.stateSecurityWidgetModels.count - 1 {
              Divider()
                .background(SKStyleAsset.constantSlate.swiftUIColor.opacity(0.3))
            }
          }
          .listRowBackground(Color.clear)
          .listRowInsets(.init(top: .zero, leading: .s4, bottom: .zero, trailing: .s4))
          .listRowSeparator(.hidden)
        }
      }
    }
    .background(Color.clear)
    .listStyle(PlainListStyle())
    .padding(.vertical, .s4)
  }
}

// MARK: - Private

private extension PasscodeSettingsScreenView {}

// MARK: - Preview

struct PasscodeSettingsScreenView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      PasscodeSettingsScreenAssembly().createModule(
        ApplicationServicesStub()
      ).viewController
    }
  }
}
