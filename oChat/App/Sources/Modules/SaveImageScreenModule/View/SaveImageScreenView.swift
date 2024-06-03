//
//  SaveImageScreenView.swift
//  oChat
//
//  Created by Vitalii Sosin on 22.05.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import PhotosUI
import Photos
import SKAbstractions

struct SaveImageScreenView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: SaveImageScreenPresenter
  
  // MARK: - Body
  
  var body: some View {
    ScrollView(showsIndicators: false) {
      VStack {
        createHighTechImageIDView()
        createTitleAndSubtitleView()
        createCopyButtonView()
      }
    }
  }
}

// MARK: - Private

private extension SaveImageScreenView {
  func createCopyButtonView() -> some View {
    RoundButtonView(
      style: .copy(text: presenter.saveButtonTitle()),
      action: {
        presenter.saveImageIDButtonTapped()
      }
    )
    .padding(.top, .s2)
  }
  
  func createHighTechImageIDView() -> some View {
    HighTechImageIDView(.init(
      image: Image(uiImage: UIImage(data: presenter.stateImageID ?? Data()) ?? UIImage()),
      imageState: .uploadedImage
    ))
    .padding(.top, .s15)
  }
  
  func createTitleAndSubtitleView() -> some View {
    TitleAndSubtitleView(
      title: .init(
        text: presenter.createHeaderDescription()
      ),
      style: .small
    )
    .padding(.horizontal, .s4)
    .padding(.top, .s2)
  }
}

// MARK: - Preview

struct SaveImageScreenView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      SaveImageScreenAssembly().createModule(.mock).viewController
    }
  }
}
