//
//  ChatNavigationModifier.swift
//
//
//  Created by Sosin Vitalii on 12.01.2023.
//

import AVKit
import SwiftUI
import SKStyle

/// View used for displaying image attachments in a gallery.
public struct GalleryView: View {
  
  @Environment(\.presentationMode) var presentationMode
  @StateObject var viewModel: FullscreenMediaPagesViewModel
  @Environment(\.chatTheme) private var theme
  
  @Binding var isShown: Bool
  @State private var selected: Int
  @State private var loadedImages = [Int: UIImage]()
  @State private var gridShown = false
  let onImageSave: ((URL) -> Void)?
  let onVideoSave: ((URL) -> Void)?
  let isDownloadAvailability: Bool
  
  public init(
    viewModel: FullscreenMediaPagesViewModel,
    isShown: Binding<Bool>,
    selected: Int,
    onImageSave: ((URL) -> Void)?,
    onVideoSave: ((URL) -> Void)?,
    isDownloadAvailability: Bool
  ) {
    _viewModel = StateObject(wrappedValue: viewModel)
    _isShown = isShown
    _selected = State(initialValue: selected)
    self.onImageSave = onImageSave
    self.onVideoSave = onVideoSave
    self.isDownloadAvailability = isDownloadAvailability
  }
  
  public var body: some View {
    GeometryReader { reader in
      VStack {
        GalleryHeaderView(
          title: viewModel.attachments[selected].type == .image ?
          ExyteChatStrings.galleryHeaderImageTitle :
            ExyteChatStrings.galleryHeaderVideoTitle,
          isShown: $isShown
        )
        .background(SKStyleAsset.onyx.swiftUIColor)
        
        TabView(selection: $selected) {
          ForEach(viewModel.attachments.enumerated().map({ $0 }), id: \.offset) { (index, attachment) in
            ZStack {
              if attachment.type == .image {
                ZoomableScrollView {
                  VStack {
                    Spacer()
                    LazyLoadingImage(
                      url: attachment.full,
                      width: reader.size.width,
                      height: reader.size.height,
                      resize: true,
                      shouldSetFrame: false,
                      onImageLoaded: { image in
                        loadedImages[index] = image
                      }
                    )
                    .aspectRatio(contentMode: .fit)
                    .frame(width: reader.size.width)
                    Spacer()
                  }
                }
                .background(SKStyleAsset.onyx.swiftUIColor)
                .tag(index)
              } else {
                StreamVideoPlayer(url: attachment.full)
                  .background(SKStyleAsset.onyx.swiftUIColor)
                  .tag(index)
              }
            }
          }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .background(SKStyleAsset.onyx.swiftUIColor)
        
        HStack(alignment: .center) {
          if isDownloadAvailability {
            Button(action: {
              if viewModel.showMinis, viewModel.attachments[selected].type == .image {
                onImageSave?(viewModel.attachments[selected].full)
              } else if viewModel.showMinis, viewModel.attachments[selected].type == .video {
                onVideoSave?(viewModel.attachments[selected].full)
              }
            }, label: {
              theme.images.mediaPicker.save
                .resizable()
                .renderingMode(.template)
                .foregroundColor(SKStyleAsset.constantAzure.swiftUIColor)
                .aspectRatio(contentMode: .fit)
                .frame(height: 24)
                .padding(.s4)
            })
          } else {
            Color.clear
              .frame(height: 24)
              .padding(.s4)
          }

          Spacer()
          
          Text("\(selected + 1)/\(viewModel.attachments.count)")
            .font(.fancy.text.regular)
          
          Spacer()
          
          Button {
            gridShown = true
          } label: {
            Image(systemName: "photo")
              .renderingMode(.template)
              .foregroundColor(SKStyleAsset.constantAzure.swiftUIColor)
          }
          .padding(.s4)
        }
        .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
      }
      .background(SKStyleAsset.onyx.swiftUIColor)
      .sheet(isPresented: $gridShown) {
        GridPhotosView(
          attachments: viewModel.attachments,
          isShown: $gridShown,
          viewModel: viewModel, 
          onSelectMedia: { index in
            selected = index
          }
        )
      }
    }
  }
  
  private var sharingContent: [UIImage] {
    if let image = loadedImages[selected] {
      return [image]
    } else {
      return []
    }
  }
}

struct StreamVideoPlayer: View {
  
  @State var player: AVPlayer
  
  init(url: URL) {
    let player = AVPlayer(url: url)
    _player = State(wrappedValue: player)
  }
  
  var body: some View {
    VideoPlayer(player: player)
      .clipped()
      .onAppear {
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: [])
      }
  }
}
