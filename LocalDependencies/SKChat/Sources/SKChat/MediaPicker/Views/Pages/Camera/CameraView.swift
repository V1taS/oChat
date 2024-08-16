//
//  Created by Sosin Vitalii on 02.06.2023.
//

import SwiftUI
import Photos

struct CustomCameraView<CameraViewContent: View>: View {
  
  @EnvironmentObject private var cameraSelectionService: CameraSelectionService
  
  public typealias CameraViewClosure = ((LiveCameraView, @escaping SimpleClosure, @escaping SimpleClosure, @escaping SimpleClosure, @escaping SimpleClosure, @escaping SimpleClosure, @escaping SimpleClosure, @escaping SimpleClosure) -> CameraViewContent)
  
  // params
  @ObservedObject var viewModel: MediaPickerViewModel
  let didTakePicture: () -> Void
  let didPressCancel: () -> Void
  var cameraViewBuilder: CameraViewClosure
  private let impactFeedback = UIImpactFeedbackGenerator(style: .soft)
  
  @StateObject private var cameraViewModel = CameraViewModel()
  
  var body: some View {
    cameraViewBuilder(
      LiveCameraView(
        session: cameraViewModel.captureSession,
        videoGravity: .resizeAspectFill,
        orientation: .portrait
      ),
      { // cancel
        if cameraSelectionService.hasSelected {
          viewModel.showingExitCameraConfirmation = true
        } else {
          didPressCancel()
        }
        impactFeedback.impactOccurred()
      },
      { viewModel.setPickerMode(.cameraSelection) }, // show preview of taken photos
      {
        // takePhoto
        cameraViewModel.takePhoto()
        impactFeedback.impactOccurred()
      },
      {
        // start record video
        Task {
          impactFeedback.impactOccurred()
          await cameraViewModel.startVideoCapture()
        }
      },
      {
        // stop record video
        cameraViewModel.stopVideoCapture()
        impactFeedback.impactOccurred()
      },
      {
        // flash off/on
        Task {
          impactFeedback.impactOccurred()
          await cameraViewModel.toggleFlash()
        }
      },
      {
        // camera back/front
        Task {
          impactFeedback.impactOccurred()
          await cameraViewModel.flipCamera()
        }
      }
    )
    .onReceive(cameraViewModel.capturedPhotoPublisher) {
      viewModel.pickedMediaUrl = $0
      didTakePicture()
    }
  }
}

struct StandardConrolsCameraView: View {
  @EnvironmentObject private var cameraSelectionService: CameraSelectionService
  @Environment(\.safeAreaInsets) private var safeAreaInsets
  @Environment(\.mediaPickerTheme) private var theme
  
  @ObservedObject var viewModel: MediaPickerViewModel
  let didTakePicture: () -> Void
  let didPressCancel: () -> Void
  let selectionParamsHolder: SelectionParamsHolder
  
  @StateObject private var cameraViewModel = CameraViewModel()
  private let impactFeedback = UIImpactFeedbackGenerator(style: .soft)
  
  @State private var capturingPhotos = true
  @State private var videoCaptureInProgress = false
  
  var body: some View {
    VStack(spacing: 0) {
      HStack {
        Button(SKChatStrings.cameraButtonCancelTitle) {
          if cameraSelectionService.hasSelected {
            viewModel.showingExitCameraConfirmation = true
          } else {
            didPressCancel()
          }
          impactFeedback.impactOccurred()
        }
        .foregroundColor(.white)
        .padding(.top, safeAreaInsets.top)
        .padding(.leading)
        .padding(.bottom)
        
        Spacer()
      }
      
      LiveCameraView(
        session: cameraViewModel.captureSession,
        videoGravity: .resizeAspectFill,
        orientation: .portrait
      )
      .overlay {
        if cameraViewModel.snapOverlay {
          Rectangle()
        }
      }
      .gesture(
        MagnificationGesture()
          .onChanged(cameraViewModel.zoomChanged(_:))
          .onEnded(cameraViewModel.zoomEnded(_:))
      )
      
      VStack(spacing: 10) {
        if cameraSelectionService.hasSelected {
          HStack {
            Button(SKChatStrings.cameraButtonDoneTitle) {
              if cameraSelectionService.hasSelected {
                viewModel.setPickerMode(.cameraSelection)
              }
              impactFeedback.impactOccurred()
            }
            Spacer()
            if selectionParamsHolder.mediaType.allowsVideo {
              photoVideoToggle
            }
            Spacer()
            Text("\(cameraSelectionService.selected.count)")
              .font(.system(size: 15))
              .padding(8)
              .overlay(Circle()
                .stroke(Color.white, lineWidth: 2))
          }
          .foregroundColor(.white)
          .padding(.horizontal, 12)
        }
        else if selectionParamsHolder.mediaType.allowsVideo {
          photoVideoToggle
        }
        
        HStack(spacing: 40) {
          Button {
            Task {
              await cameraViewModel.toggleFlash()
              impactFeedback.impactOccurred()
            }
          } label: {
            Image(cameraViewModel.flashEnabled ? "FlashOn" : "FlashOff", bundle: .current)
          }
          
          if capturingPhotos {
            takePhotoButton
          } else if !videoCaptureInProgress {
            startVideoCaptureButton
          } else {
            stopVideoCaptureButton
          }
          
          Button {
            Task {
              await cameraViewModel.flipCamera()
              impactFeedback.impactOccurred()
            }
          } label: {
            Image("FlipCamera", bundle: .current)
          }
        }
      }
      .padding(.top, 24)
      .padding(.bottom, safeAreaInsets.bottom + 16)
    }
    .background(theme.main.cameraBackground)
    .onEnteredBackground(perform: cameraViewModel.stopSession)
    .onEnteredForeground(perform: cameraViewModel.startSession)
    .onReceive(cameraViewModel.capturedPhotoPublisher) {
      viewModel.pickedMediaUrl = $0
      didTakePicture()
    }
  }
  
  var photoVideoToggle: some View {
    HStack {
      Button(SKChatStrings.cameraButtonVideoTitle) {
        capturingPhotos = false
        impactFeedback.impactOccurred()
      }
      .foregroundColor(capturingPhotos ? Color.white : Color.yellow)
      
      Button(SKChatStrings.cameraButtonPhotoTitle) {
        capturingPhotos = true
        impactFeedback.impactOccurred()
      }
      .foregroundColor(capturingPhotos ? Color.yellow : Color.white)
    }
  }
  
  var takePhotoButton: some View {
    ZStack {
      Circle()
        .stroke(Color.white.opacity(0.4), lineWidth: 6)
        .frame(width: 72, height: 72)
      
      Button {
        cameraViewModel.takePhoto()
        impactFeedback.impactOccurred()
      } label: {
        Circle()
          .foregroundColor(.white)
          .frame(width: 60, height: 60)
      }
    }
  }
  
  var startVideoCaptureButton: some View {
    ZStack {
      Circle()
        .stroke(Color.white.opacity(0.4), lineWidth: 6)
        .frame(width: 72, height: 72)
      
      Button {
        Task {
          await cameraViewModel.startVideoCapture()
          videoCaptureInProgress = true
          impactFeedback.impactOccurred()
        }
      } label: {
        Circle()
          .foregroundColor(.red)
          .frame(width: 60, height: 60)
      }
    }
  }
  
  var stopVideoCaptureButton: some View {
    ZStack {
      Circle()
        .stroke(Color.white.opacity(0.4), lineWidth: 6)
        .frame(width: 72, height: 72)
      
      Button {
        cameraViewModel.stopVideoCapture()
        videoCaptureInProgress = false
        impactFeedback.impactOccurred()
      } label: {
        RoundedRectangle(cornerRadius: 10)
          .foregroundColor(.red)
          .frame(width: 40, height: 40)
      }
    }
  }
}
