//
//  RemoveWalletSheetView.swift
//  oChat
//
//  Created by Vitalii Sosin on 09.05.2024.
//

import SKStyle
import SKUIKit
import SwiftUI

struct RemoveWalletSheetView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: RemoveWalletSheetPresenter
  
  // MARK: - Body
  
  var body: some View {
    CustomSheetView {
      VStack(spacing: .s5) {
        VStack(alignment: .leading, spacing: .s4) {
          Text(presenter.getHeaderTitle())
            .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
            .font(.fancy.text.title)
            .lineLimit(2)
          
          Text(presenter.getTipsOneTitle())
            .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
            .font(.fancy.text.regular)
          
          Text(presenter.getTipsTwoTitle())
            .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
            .font(.fancy.text.regular)
        }
        
        VStack(spacing: .zero) {
          MainButtonView(
            text: presenter.getMainButtoTitle(),
            style: .critical,
            action: {
              presenter.moduleOutput?.removeWalletSheetWasTapped()
            }
          )
        }
      }
    }
  }
}

// MARK: - Private

private extension RemoveWalletSheetView {}

// MARK: - Preview

struct RemoveWalletSheetView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      RemoveWalletSheetAssembly().createModule().viewController
    }
  }
}
