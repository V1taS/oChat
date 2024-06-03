//
//  SettingsScreenView.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions

struct SettingsScreenView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: SettingsScreenPresenter
  
  // MARK: - Body
  
  var body: some View {
    VStack(spacing: .zero) {
      ScrollView(.vertical, showsIndicators: false) {
        VStack(spacing: .s6) {
          WidgetCryptoView(presenter.getSecuritySectionsModels())
        }
        .padding(.horizontal, .s4)
        .padding(.top, .s3)
        
        applicationVersionView()
          .padding(.top, .s3)
      }
    }
  }
}

// MARK: - Private

private extension SettingsScreenView {
  func applicationVersionView() -> some View {
    VStack(spacing: .zero) {
//      SKUIKitAsset.skWatermark.swiftUIImage
//        .resizable()
//        .renderingMode(.template)
//        .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
//        .aspectRatio(contentMode: .fit)
//        .frame(height: 50)
//        .padding(.s4)
      
      VStack(spacing: .s1) {
        Text(presenter.stateApplicationTitle)
          .foregroundColor(SKStyleAsset.constantSlate.swiftUIColor.opacity(0.3))
          .font(.fancy.text.regularMedium)
        
        Text(presenter.getAplicationVersion())
          .foregroundColor(SKStyleAsset.constantSlate.swiftUIColor.opacity(0.2))
          .font(.fancy.text.small)
      }
      .offset(y: -.s3)
    }
    .padding(.top, .s10)
  }
}

// MARK: - Preview

struct SettingsScreenView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      SettingsScreenAssembly().createModule(
        ApplicationServicesStub()
      ).viewController
    }
  }
}
