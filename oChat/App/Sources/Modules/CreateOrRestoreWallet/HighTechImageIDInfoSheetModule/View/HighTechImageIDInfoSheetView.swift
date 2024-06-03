//
//  HighTechImageIDInfoSheetView.swift
//  oChat
//
//  Created by Vitalii Sosin on 20.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI

struct HighTechImageIDInfoSheetView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: HighTechImageIDInfoSheetPresenter
  
  // MARK: - Body
  
  var body: some View {
    CustomSheetView {
      VStack(spacing: .zero) {
        createHighTechImageIDProtectionView()
        Spacer()
        HStack { Spacer() }
      }
    }
  }
}

// MARK: - Private

private extension HighTechImageIDInfoSheetView {
  func createHighTechImageIDProtectionView() -> some View {
    let model = presenter.getHighTechImageIDProtectionModel()
    return VStack(spacing: .s4) {
      Text(model.title)
        .font(.fancy.text.title)
        .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
        .multilineTextAlignment(.center)
      
      Text(model.description)
        .font(.fancy.text.small)
        .foregroundColor(SKStyleAsset.slate.swiftUIColor)
        .multilineTextAlignment(.leading)
    }
  }
}

// MARK: - Preview

struct HighTechImageIDInfoSheetView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      HighTechImageIDInfoSheetAssembly().createModule().viewController
    }
  }
}
