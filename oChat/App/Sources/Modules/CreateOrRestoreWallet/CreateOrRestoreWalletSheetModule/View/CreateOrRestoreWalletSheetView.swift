//
//  CreateOrRestoreWalletSheetView.swift
//  oChat
//
//  Created by Vitalii Sosin on 17.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI

struct CreateOrRestoreWalletSheetView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: CreateOrRestoreWalletSheetPresenter
  
  // MARK: - Body
  
  var body: some View {
    CustomSheetView {
      VStack(spacing: .s4) {
        ForEach(presenter.widgetModels, id: \.self) { widgetsModel in
          WidgetCryptoView(
            .init(
              leftSide: .init(
                imageModel: .custom(
                  image: widgetsModel.image,
                  color: SKStyleAsset.azure.swiftUIColor
                ),
                titleModel: .init(text: widgetsModel.title),
                descriptionModel: .init(
                  text: widgetsModel.description,
                  textStyle: .netural
                )
              ),
              isSelectable: true,
              backgroundColor: SKStyleAsset.constantSlate.swiftUIColor.opacity(0.1),
              action: widgetsModel.action
            )
          )
        }
      }
    }
  }
}

// MARK: - Private

private extension CreateOrRestoreWalletSheetView {}

// MARK: - Preview

struct CreateOrRestoreWalletSheetView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      CreateOrRestoreWalletSheetAssembly()
        .createModule(sheetType: .createWallet).viewController
    }
  }
}
