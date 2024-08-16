//
//  Created by Sosin Vitalii on 02.06.2023.
//

import SwiftUI

struct LiveCameraCell: View {
  
  let action: () -> Void
  
  @StateObject private var liveCameraViewModel = LiveCameraViewModel()
  @State private var orientation = UIDevice.current.orientation
  
  var body: some View {
    Button {
      action()
    } label: {
      LiveCameraView(
        session: liveCameraViewModel.captureSession,
        videoGravity: .resizeAspectFill,
        orientation: orientation
      )
      .overlay(
        Image(systemName: "camera")
          .foregroundColor(.white)
      )
    }
    .onEnteredBackground(perform: liveCameraViewModel.stopSession)
    .onEnteredForeground(perform: liveCameraViewModel.startSession)
    .onRotate { orientation = $0 }
  }
}
