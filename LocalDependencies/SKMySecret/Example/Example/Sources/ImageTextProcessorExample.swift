//
//  ImageTextProcessorExample.swift
//  Example
//
//  Created by Vitalii Sosin on 15.02.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SwiftUI
import PhotosUI
import Photos
import SKMySecret

// swiftlint:disable line_length
struct ImageTextProcessorExample: View {
  @State private var avatarImage: Image?
  @State private var avatarItem: PhotosPickerItem?
  @State private var isLoading = false
  @State private var currentImageData: Data?
  @State private var displayText: String = ""
  
  @State private var textField: String = "BFV2w3t1gjJr43ya9kPPHgiDy7g6jCpFgp2u4EnADzh39xVBSdwXcCLNzW2RdI1E/dHw1g2Nyk6qAJOrttqBk1vISGYOE/WQ8XeWTRJprbS/BB8QPTuloJyUFOFO+p1o0ytwgta8GVGARyyyXYRGJhEiS/PY0jTCJ+qQLaXFfGVL5NCUlwP5uTb34mZMvXfiIJ43kEl/Hi+LkRFwRn44mWSx7VWlh2KiHgcuJUGOdyTt1CUBx38JNNf8udyE1TIjcfNNvyHMKeplBdakyNyDZB3XHFK9+g5QylY0Zj0qfV0bDPHCCwJN22HXZ4Id3DpDau3DSfU+iJzzlHDARQBGeSt5bfTwMvid1A=="
  private let steganographer: ISteganographer = Steganographer()
  @State private var password = ""
  
  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      VStack(spacing: .zero) {
        if let avatarImage {
          avatarImage
            .resizable()
            .scaledToFill()
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2)
            .cornerRadius(24)
        }
        
        if !displayText.isEmpty {
          Text(displayText)
            .font(.headline)
            .lineLimit(.max)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
            .background(Color.gray)
            .cornerRadius(16)
            .padding(.top, 24)
            .onTapGesture {
              UIPasteboard.general.string = displayText
              displayText = "✅ Текст скопирован в буфер обмена"
            }
            .padding(.top, 60)
        }
        
        Spacer()
        
        if isLoading {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
        } else {
          Color.white
            .frame(height: avatarImage == nil ? UIScreen.main.bounds.height / 2.5 : .zero)
          
          VStack(alignment: .leading, spacing: 32) {
            PhotosPicker(
              "Выбрать изображение",
              selection: $avatarItem,
              matching: .any(of: [.images, .screenshots])
            )
            
            TextField("Текст для кодирования", text: $textField, axis: .vertical)
              .autocorrectionDisabled(true)
              .lineLimit(.max)
              .font(.subheadline)
              .foregroundColor(.black)
              .textFieldStyle(.roundedBorder)
            
            Button("Закодировать и сохранить") {
              encodeAndSave()
            }
            .foregroundColor(.red)
          }
          .padding(24)
          
          Button("Раскодировать Картинку") {
            decodeImage()
          }
          .padding()
          .foregroundColor(.white)
          .background(Color.blue)
          .clipShape(RoundedRectangle(cornerRadius: 16))
          .padding(.top, 24)
          
          if !displayText.isEmpty {
            Button("Очистить") {
              avatarImage = nil
              avatarItem = nil
              currentImageData = nil
              displayText = ""
              textField = ""
            }
            .padding()
            .foregroundColor(.red)
            .padding(.top, 24)
          }
        }
        Spacer()
      }
    }
    .edgesIgnoringSafeArea(.all)
    .onChange(of: avatarItem) { newValue in
      Task {
        await loadImage(newValue: newValue)
      }
    }
  }
}

// MARK: - Private

private extension ImageTextProcessorExample {
  func loadImage(newValue: PhotosPickerItem?) async {
    isLoading = true
    defer { isLoading = false }
    guard let newValue = newValue else {
      displayText = "❌ Картинка не выбрана"
      return
    }
    if let imageData = try? await newValue.loadTransferable(type: Data.self) {
      currentImageData = imageData
      self.avatarImage = Image(uiImage: UIImage(data: imageData) ?? UIImage())
    }
  }
  
  func saveImageToGallery() {
    UIImageWriteToSavedPhotosAlbum(UIImage(data: currentImageData!)!, nil, nil, nil)
  }
  
  func decodeImage() {
    isLoading = true
    guard let currentImageData else {
      displayText = "❌ ImageURL не доступен"
      return
    }
    
    steganographer.getTextBase64From(image: currentImageData) { result in
      switch result {
      case let .success(textBase64Data):
        displayText = textBase64Data
      case .failure:
        displayText = "❌"
      }
      isLoading = false
    }
  }
  
  func encodeAndSave() {
    isLoading = true
    guard let currentImageData else {
      displayText = "❌ ImageURL не доступен"
      return
    }
    
    steganographer.hideTextBase64(textField, withImage: currentImageData) { result in
      switch result {
      case let .success(imageData):
        self.currentImageData = imageData ?? Data()
        saveImageToGallery()
        displayText = "✅ Успех"
      case .failure(_):
        displayText = "❌"
      }
      isLoading = false
    }
  }
}

#Preview {
  ImageTextProcessorExample()
}
