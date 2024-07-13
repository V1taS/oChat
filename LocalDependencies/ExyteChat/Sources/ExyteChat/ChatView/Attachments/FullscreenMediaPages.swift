//
//  Created by Sosin Vitalii on 22.06.2022.
//

import Foundation
import SwiftUI
import SKStyle

struct FullscreenMediaPages: View {
  
  @Environment(\.chatTheme) private var theme
  @Environment(\.mediaPickerTheme) var pickerTheme
  
  @StateObject var viewModel: FullscreenMediaPagesViewModel
  var safeAreaInsets: EdgeInsets
  var onClose: () -> Void
  let onImageSave: (URL) -> Void
  let onVideoSave: (URL) -> Void
  let isDownloadAvailability: Bool
  
  var body: some View {
    ZStack {
      SKStyleAsset.onyx.swiftUIColor
        .opacity(max((200.0 - viewModel.offset.height) / 200.0, 0.5))
      VStack {
        TabView(selection: $viewModel.index) {
          ForEach(viewModel.attachments.enumerated().map({ $0 }), id: \.offset) { (index, attachment) in
            AttachmentsPage(attachment: attachment)
              .tag(index)
              .frame(maxWidth: .infinity, maxHeight: .infinity)
              .allowsHitTesting(false)
              .ignoresSafeArea()
          }
          .ignoresSafeArea()
        }
        .environmentObject(viewModel)
        .tabViewStyle(.page(indexDisplayMode: .never))
      }
      .offset(viewModel.offset)
      .onTapGesture {
        viewModel.showMinis.toggle()
      }
      
      VStack {
        Spacer()
        ScrollViewReader { proxy in
          if viewModel.showMinis {
            ScrollView(.horizontal) {
              HStack(spacing: 2) {
                ForEach(viewModel.attachments.enumerated().map({ $0 }), id: \.offset) { (index, attachment) in
                  AttachmentCell(attachment: attachment) { _ in
                    withAnimation {
                      viewModel.index = index
                    }
                  }
                  .frame(width: 100, height: 100)
                  .cornerRadius(4)
                  .clipped()
                  .id(index)
                  .overlay {
                    if viewModel.index == index {
                      RoundedRectangle(cornerRadius: 4)
                        .stroke(SKStyleAsset.constantAzure.swiftUIColor, lineWidth: 2)
                    }
                  }
                  .padding(.vertical, 1)
                }
              }
            }
            .padding([.top, .horizontal], 12)
            .background(.clear)
            .onAppear {
              proxy.scrollTo(viewModel.index)
            }
            .onChange(of: viewModel.index) { newValue in
              withAnimation {
                proxy.scrollTo(newValue, anchor: .center)
              }
            }
          }
        }
        .offset(y: -safeAreaInsets.bottom)
      }
      .offset(viewModel.offset)
    }
    .ignoresSafeArea()
    .overlay(alignment: .top) {
      if viewModel.showMinis {
        Text("\(viewModel.index + 1)/\(viewModel.attachments.count)")
          .foregroundColor(SKStyleAsset.constantAzure.swiftUIColor)
          .offset(y: safeAreaInsets.top)
      }
    }
    .overlay(alignment: .topLeading) {
      if viewModel.showMinis {
        Button(action: onClose) {
          theme.images.mediaPicker.cross
            .resizable()
            .renderingMode(.template)
            .foregroundColor(SKStyleAsset.constantAzure.swiftUIColor)
            .aspectRatio(contentMode: .fit)
            .frame(height: 24)
            .padding(5)
        }
        .tint(SKStyleAsset.constantAzure.swiftUIColor)
        .padding(.leading, 15)
        .offset(y: safeAreaInsets.top - 5)
      }
    }
    .overlay(alignment: .topTrailing) {
      if isDownloadAvailability, viewModel.showMinis, viewModel.attachments[viewModel.index].type == .image {
        Button(action: {
          onImageSave(viewModel.attachments[viewModel.index].full)
        }) {
          theme.images.mediaPicker.save
            .resizable()
            .renderingMode(.template)
            .foregroundColor(SKStyleAsset.constantAzure.swiftUIColor)
            .aspectRatio(contentMode: .fit)
            .frame(height: 24)
            .padding(5)
        }
        .tint(SKStyleAsset.constantAzure.swiftUIColor)
        .padding(.trailing, 15)
        .offset(y: safeAreaInsets.top - 5)
      } else if viewModel.showMinis, viewModel.attachments[viewModel.index].type == .video {
        HStack(alignment: .center,spacing: 20) {
          if isDownloadAvailability {
            Button(action: {
              onVideoSave(viewModel.attachments[viewModel.index].full)
            }) {
              theme.images.mediaPicker.save
                .resizable()
                .renderingMode(.template)
                .foregroundColor(SKStyleAsset.constantAzure.swiftUIColor)
                .aspectRatio(contentMode: .fit)
                .frame(height: 24)
            }
          }
          
          (viewModel.videoPlaying ? theme.images.fullscreenMedia.pause : theme.images.fullscreenMedia.play)
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
            .padding(5)
            .contentShape(Rectangle())
            .onTapGesture {
              viewModel.toggleVideoPlaying()
            }
          
          (!viewModel.videoMuted ? theme.images.fullscreenMedia.unmute : theme.images.fullscreenMedia.mute)
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
            .padding(5)
            .contentShape(Rectangle())
            .onTapGesture {
              viewModel.toggleVideoMuted()
            }
        }
        .foregroundColor(SKStyleAsset.constantAzure.swiftUIColor)
        .padding(.trailing, 10)
        .offset(y: safeAreaInsets.top - 5)
      }
    }
  }
}

private extension FullscreenMediaPages {
  func closeSize(from size: CGSize) -> CGSize {
    CGSize(width: 0, height: max(size.height, 0))
  }
}
