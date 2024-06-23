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
    List {
      ForEach(presenter.stateSectionsModels.indices, id: \.self) { index in
        VStack(spacing: .zero) {
          WidgetCryptoView(presenter.stateSectionsModels[index])
            .if(index == 0) { view in
              view
                .clipShape(RoundedCornerShape(corners: [.topLeft, .topRight], radius: .s4))
            }
            .if(index == presenter.stateSectionsModels.count - 1) { view in
              view
                .clipShape(RoundedCornerShape(corners: [.bottomLeft, .bottomRight], radius: .s4))
            }
          
          if index < presenter.stateSectionsModels.count - 1 {
            Divider()
              .background(SKStyleAsset.slate.swiftUIColor.opacity(0.3))
          }
          if index == presenter.stateSectionsModels.count - 1 {
            applicationVersionView()
              .padding(.top, .s3)
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

private extension SettingsScreenView {
  func applicationVersionView() -> some View {
    VStack(spacing: .zero) {
      Image(
        uiImage: UIImage(
          named: SKStyleAsset.oChatInProgress.name,
          in: SKStyleResources.bundle,
          with: nil
        ) ?? UIImage()
      )
      .resizable()
      .renderingMode(.template)
      .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
      .aspectRatio(contentMode: .fit)
      .opacity(0.3)
      .frame(height: 50)
      .padding(.s4)
      
      VStack(spacing: .s1) {
        Text(presenter.stateApplicationTitle)
          .foregroundColor(SKStyleAsset.constantSlate.swiftUIColor.opacity(0.3))
          .font(.fancy.text.regularMedium)
        
        Text(presenter.getAplicationVersion())
          .foregroundColor(SKStyleAsset.constantSlate.swiftUIColor.opacity(0.3))
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

struct RoundedCornerShape: Shape {
  var corners: UIRectCorner
  var radius: CGFloat
  
  func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(
      roundedRect: rect,
      byRoundingCorners: corners,
      cornerRadii: CGSize(width: radius, height: radius)
    )
    return Path(path.cgPath)
  }
}
