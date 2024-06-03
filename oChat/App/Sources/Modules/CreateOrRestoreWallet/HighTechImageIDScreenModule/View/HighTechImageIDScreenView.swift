//
//  HighTechImageIDScreenView.swift
//  oChat
//
//  Created by Vitalii Sosin on 19.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import PhotosUI
import Photos
import SKAbstractions

struct HighTechImageIDScreenView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: HighTechImageIDScreenPresenter
  
  // MARK: - Private properties
  
  @State private var imageItem: PhotosPickerItem?
  
  // MARK: - Body
  
  var body: some View {
    VStack(spacing: .zero) {
      createContentView()
      HStack { Spacer() }
    }
    .onChange(of: imageItem) { newValue in
      Task {
        await presenter.setImageID(newValue)
        presenter.setImageIDState()
      }
    }
  }
}

// MARK: - Private

private extension HighTechImageIDScreenView {
  func createScrollViewContentView<Content: View>(content: @escaping () -> Content) -> AnyView {
    return AnyView(
      ScrollView(.vertical, showsIndicators: false) {
        VStack(spacing: .s6) {
          createTitleAndSubtitleView()
          content()
        }
      }
    )
  }
  
  func createContentView() -> AnyView {
    switch presenter.stateCurrentStateScreen {
    case let .generateImageID(result):
      switch result {
      case .initialState:
        return AnyView(
          createScrollViewContentView {
            VStack(spacing: .s4) {
              createStepDescriptionView()
              createHighTechImageIDView()
            }
          }
        )
      case .passCodeImage:
        return AnyView(
          VStack(spacing: .s5) {
            createScrollViewContentView {
              VStack(spacing: .s4) {
                createStepDescriptionView()
                WidgetCryptoView(presenter.createAdditionProtectionModel())
                  .padding(.horizontal, .s4)
              }
            }
            
            createMainButtonView()
          }
        )
      case .startUploadImage:
        return AnyView(
          createScrollViewContentView {
            VStack(spacing: .s4) {
              createStepDescriptionView()
              createHighTechImageIDView()
            }
          }
        )
      case .finish:
        return AnyView(
          VStack(spacing: .s5) {
            createScrollViewContentView {
              VStack(spacing: .s4) {
                createStepDescriptionView()
                createHighTechImageIDView()
                createSaveImageIDButtonView()
              }
            }
            createTermsOfAgreementView()
            createMainButtonView()
          }
        )
      }
    case let .loginImageID(result):
      switch result {
      case .initialState:
        return AnyView(
          createScrollViewContentView {
            VStack(spacing: .s4) {
              createStepDescriptionView()
              createHighTechImageIDView()
            }
          }
        )
      case .passCodeImage:
        return AnyView(
          VStack(spacing: .s5) {
            createScrollViewContentView {
              VStack(spacing: .s4) {
                createStepDescriptionView()
                WidgetCryptoView(presenter.createAdditionProtectionModel())
                  .padding(.horizontal, .s4)
              }
            }
            createMainButtonView()
          }
        )
      case .startUploadImage:
        return AnyView(
          createScrollViewContentView {
            VStack(spacing: .s4) {
              createStepDescriptionView()
              createHighTechImageIDView()
            }
          }
        )
      case .finish:
        return AnyView(
          VStack(spacing: .s5) {
            createScrollViewContentView {
              VStack(spacing: .s4) {
                createStepDescriptionView()
                createHighTechImageIDView()
              }
            }
            createMainButtonView()
          }
        )
      }
    }
  }
  
  func createSaveImageIDButtonView() -> some View {
    RoundButtonView(
      isEnabled: true,
      style: .custom(
        text: presenter.stateSaveImageIDButtonTitle,
        backgroundColor: SKStyleAsset.azure.swiftUIColor
      ),
      action: {
        presenter.setIsSaveImageID(value: true)
        presenter.saveImageToGallery()
      }
    )
  }
  
  func createMainButtonView() -> some View {
    MainButtonView(
      text: presenter.createButtonTitle(),
      isEnabled: presenter.isValidationMainButton(),
      style: presenter.isValidationMainButton() ? .primary : .secondary,
      action: {
        presenter.continueButtonTapped()
      }
    )
    .padding(.horizontal, .s4)
    .padding(.bottom, .s4)
  }
  
  func createTermsOfAgreementView() -> some View {
    CheckmarkView(
      text: presenter.createTermsOfAgreementTitle(),
      action: { newValue in
        presenter.confirmationRequirements(value: newValue)
      }
    )
    .padding(.horizontal, .s4)
  }
  
  func createHighTechImageIDView() -> some View {
    PhotosPicker(
      selection: $imageItem,
      matching: .any(of: [.images, .screenshots])
    ) {
      HighTechImageIDView(.init(
        image: Image(uiImage: UIImage(data: presenter.stateImageID ?? Data()) ?? UIImage()),
        imageState: presenter.stateCurrentStateScreen.mapTo()
      ))
    }
    .disabled(presenter.stateIsDisabledPhotosPicker)
  }
  
  func createStepDescriptionView() -> some View {
    HStack {
      Text(presenter.createStepDescription())
        .font(.fancy.text.small)
        .foregroundColor(SKStyleAsset.slate.swiftUIColor)
        .allowsHitTesting(false)
      Spacer()
    }
    .padding(.horizontal, .s4)
  }
  
  func createTitleAndSubtitleView() -> some View {
    TitleAndSubtitleView(
      title: .init(
        text: presenter.createHeaderDescription()
      ),
      style: .small
    )
    .padding(.horizontal, .s4)
    .padding(.top, .s5)
  }
}

// MARK: - Preview

struct HighTechImageIDScreenView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      HighTechImageIDScreenAssembly().createModule(
        state: .generateImageID(.initialState),
        services: ApplicationServicesStub(),
        walletModel: .mock
      ).viewController
    }
  }
}
