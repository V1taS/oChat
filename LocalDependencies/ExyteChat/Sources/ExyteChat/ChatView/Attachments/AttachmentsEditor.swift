//
//  AttachmentsEditor.swift
//  Chat
//
//  Created by Sosin Vitalii on 22.06.2022.
//

import SwiftUI
import ExyteMediaPicker
import ActivityIndicatorView
import SKStyle

struct AttachmentsEditor<InputViewContent: View>: View {
  
  typealias InputViewBuilderClosure = ChatView<EmptyView, InputViewContent>.InputViewBuilderClosure
  
  @Environment(\.chatTheme) var theme
  @Environment(\.mediaPickerTheme) var pickerTheme
  
  @EnvironmentObject private var keyboardState: KeyboardState
  @EnvironmentObject private var globalFocusState: GlobalFocusState
  
  @ObservedObject var inputViewModel: InputViewModel
  
  var inputViewBuilder: InputViewBuilderClosure?
  var chatTitle: String?
  var messageUseMarkdown: Bool
  var orientationHandler: MediaPickerOrientationHandler
  var mediaPickerSelectionParameters: MediaPickerParameters?
  var availableInput: AvailableInputType
  var placeholder: String
  var onChange: (_ newValue: String) -> Void
  private let impactFeedback = UIImpactFeedbackGenerator(style: .soft)
  
  @State private var seleсtedMedias: [Media] = []
  @State private var currentFullscreenMedia: Media?
  
  var showingAlbums: Bool {
    inputViewModel.mediaPickerMode == .albums
  }
  
  var body: some View {
    ZStack {
      mediaPicker
      
      if inputViewModel.showActivityIndicator {
        ActivityIndicator()
      }
    }
  }
  
  var mediaPicker: some View {
    GeometryReader { g in
      MediaPicker(isPresented: $inputViewModel.showPicker) {
        seleсtedMedias = $0
        assembleSelectedMedia()
      } albumSelectionBuilder: { _, albumSelectionView, _ in
        VStack {
          albumSelectionHeaderView
            .padding(.top, g.safeAreaInsets.top)
          albumSelectionView
          Spacer()
          inputView
            .padding(.bottom, g.safeAreaInsets.bottom)
        }
        .background(SKStyleAsset.onyx.swiftUIColor)
        .ignoresSafeArea()
      } cameraSelectionBuilder: { _, cancelClosure, cameraSelectionView in
        VStack {
          cameraSelectionHeaderView(cancelClosure: cancelClosure)
            .padding(.top, g.safeAreaInsets.top)
          cameraSelectionView
          Spacer()
          inputView
            .padding(.bottom, g.safeAreaInsets.bottom)
        }
        .ignoresSafeArea()
      }
      .didPressCancelCamera {
        inputViewModel.showPicker = false
        impactFeedback.impactOccurred()
      }
      .currentFullscreenMedia($currentFullscreenMedia)
      .showLiveCameraCell()
      .setSelectionParameters(mediaPickerSelectionParameters)
      .pickerMode($inputViewModel.mediaPickerMode)
      .orientationHandler(orientationHandler)
      .padding(.top)
      .background(SKStyleAsset.onyx.swiftUIColor)
      .ignoresSafeArea(.all)
      .onChange(of: currentFullscreenMedia) { newValue in
        assembleSelectedMedia()
      }
      .onChange(of: inputViewModel.showPicker) { _ in
        let showFullscreenPreview = mediaPickerSelectionParameters?.showFullscreenPreview ?? true
        let selectionLimit = mediaPickerSelectionParameters?.selectionLimit ?? 1
        
        if selectionLimit == 1 && !showFullscreenPreview {
          assembleSelectedMedia()
          inputViewModel.send()
        }
      }
    }
  }
  
  func assembleSelectedMedia() {
    if !seleсtedMedias.isEmpty {
      inputViewModel.attachments.medias = seleсtedMedias
    } else if let media = currentFullscreenMedia {
      inputViewModel.attachments.medias = [media]
    } else {
      inputViewModel.attachments.medias = []
    }
  }
  
  @ViewBuilder
  var inputView: some View {
    Group {
      if let inputViewBuilder = inputViewBuilder {
        inputViewBuilder(
          $inputViewModel.attachments.text,
          inputViewModel.attachments,
          inputViewModel.state,
          .signature,
          inputViewModel.inputViewAction()
        ) {
          globalFocusState.focus = nil
        }
      } else {
        InputView(
          viewModel: inputViewModel,
          inputFieldId: UUID(),
          style: .signature,
          availableInput: availableInput,
          messageUseMarkdown: messageUseMarkdown,
          placeholder: placeholder,
          onChange: onChange
        )
      }
    }
  }
  
  var albumSelectionHeaderView: some View {
    ZStack {
      HStack {
        Button {
          seleсtedMedias = []
          inputViewModel.showPicker = false
          impactFeedback.impactOccurred()
        } label: {
          Text(ExyteChatStrings.attachmentsEditorButtonCancelTitle)
            .foregroundColor(SKStyleAsset.constantAzure.swiftUIColor)
        }
        
        Spacer()
      }
      
      HStack {
        Text(ExyteChatStrings.attachmentsEditorButtonRecentsTitle)
          .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
        Image(systemName: "chevron.down")
          .foregroundColor(SKStyleAsset.constantAzure.swiftUIColor)
          .rotationEffect(Angle(radians: showingAlbums ? .pi : 0))
      }
      .foregroundColor(.white)
      .onTapGesture {
        impactFeedback.impactOccurred()
        withAnimation {
          inputViewModel.mediaPickerMode = showingAlbums ? .photos : .albums
        }
      }
      .frame(maxWidth: .infinity)
    }
    .padding(.horizontal)
    .padding(.bottom, 5)
  }
  
  func cameraSelectionHeaderView(cancelClosure: @escaping ()->()) -> some View {
    HStack {
      Button {
        cancelClosure()
        impactFeedback.impactOccurred()
      } label: {
        Image(systemName: "xmark")
          .resizable()
          .foregroundColor(SKStyleAsset.constantAzure.swiftUIColor)
          .frame(width: 16, height: 16)
      }
      .padding(.trailing, 30)
      
      if let chatTitle = chatTitle {
        theme.images.mediaPicker.chevronRight
        Text(chatTitle)
          .font(.title3)
          .foregroundColor(SKStyleAsset.constantAzure.swiftUIColor)
      }
      
      Spacer()
    }
    .padding(.horizontal)
    .padding(.bottom, 10)
  }
}
