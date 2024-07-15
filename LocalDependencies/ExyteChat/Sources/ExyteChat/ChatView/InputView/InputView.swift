//
//  InputView.swift
//  Chat
//
//  Created by Sosin Vitalii on 25.05.2022.
//

import SwiftUI
import ExyteMediaPicker
import SKStyle

public enum InputViewStyle {
  case message
  case signature
}

public enum InputViewAction {
  case photo
  case add
  case camera
  case send
  
  case recordAudioHold
  case recordAudioTap
  case recordAudioLock
  case stopRecordAudio
  case deleteRecord
  case playRecord
  case pauseRecord
  //    case location
  //    case document
}

public enum InputViewState {
  case empty
  case hasTextOrMedia
  
  case waitingForRecordingPermission
  case isRecordingHold
  case isRecordingTap
  case hasRecording
  case playingRecording
  case pausedRecording
  
  var canSend: Bool {
    switch self {
    case .hasTextOrMedia, .hasRecording, .isRecordingTap, .playingRecording, .pausedRecording: return true
    default: return false
    }
  }
}

public enum AvailableInputType {
  case full // media + text + audio
  case textAndMedia
  case textAndAudio
  case textOnly
  
  var isMediaAvailable: Bool {
    [.full, .textAndMedia].contains(self)
  }
  
  var isAudioAvailable: Bool {
    [.full, .textAndAudio].contains(self)
  }
}

public struct InputViewAttachments {
  public var text: String = ""
  public var medias: [Media] = []
  public var recording: Recording?
  public var replyMessage: ReplyMessage?
}

struct InputView: View {
  
  @Environment(\.chatTheme) private var theme
  @Environment(\.mediaPickerTheme) private var pickerTheme
  
  @ObservedObject var viewModel: InputViewModel
  var inputFieldId: UUID
  var style: InputViewStyle
  var availableInput: AvailableInputType
  var messageUseMarkdown: Bool
  var placeholder: String
  var onChange: (_ newValue: String) -> Void
  
  @StateObject var recordingPlayer = RecordingPlayer()
  
  private var onAction: (InputViewAction) -> Void {
    viewModel.inputViewAction()
  }
  
  private var state: InputViewState {
    viewModel.state
  }
  
  @State private var overlaySize: CGSize = .zero
  
  @State private var recordButtonFrame: CGRect = .zero
  @State private var lockRecordFrame: CGRect = .zero
  @State private var deleteRecordFrame: CGRect = .zero
  
  @State private var dragStart: Date?
  @State private var tapDelayTimer: Timer?
  @State private var cancelGesture = false
  private let tapDelay = 0.2
  
  var body: some View {
    VStack {
      viewOnTop
      HStack(alignment: .bottom, spacing: 10) {
        HStack(alignment: .bottom, spacing: 0) {
          leftView
          middleView
          rightView
        }
        .background {
          RoundedRectangle(cornerRadius: 18)
            .fill(fieldBackgroundColor)
        }
        
        rightOutsideButton
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
    }
    .background(backgroundColor)
    .onAppear {
      viewModel.recordingPlayer = recordingPlayer
    }
  }
  
  @ViewBuilder
  var leftView: some View {
    if [.isRecordingTap, .isRecordingHold, .hasRecording, .playingRecording, .pausedRecording].contains(state) {
      deleteRecordButton
    } else {
      switch style {
      case .message:
        if availableInput.isMediaAvailable {
          attachButton
        }
      case .signature:
        if viewModel.mediaPickerMode == .cameraSelection {
          addButton
        } else {
          Color.clear.frame(width: 12, height: 1)
        }
      }
    }
  }
  
  @ViewBuilder
  var middleView: some View {
    Group {
      switch state {
      case .hasRecording, .playingRecording, .pausedRecording:
        recordWaveform
      case .isRecordingHold:
        swipeToCancel
      case .isRecordingTap:
        recordingInProgress
      default:
        TextInputView(
          text: $viewModel.attachments.text,
          inputFieldId: inputFieldId,
          style: style,
          availableInput: availableInput,
          placeholder: placeholder,
          onChange: onChange
        )
      }
    }
    .frame(minHeight: 48)
  }
  
  @ViewBuilder
  var rightView: some View {
    Group {
      switch state {
      case .empty, .waitingForRecordingPermission:
        if case .message = style, availableInput.isMediaAvailable {
          cameraButton
        }
      case .isRecordingHold, .isRecordingTap:
        recordDurationInProcess
      case .hasRecording:
        recordDuration
      case .playingRecording, .pausedRecording:
        recordDurationLeft
      default:
        Color.clear.frame(width: 8, height: 1)
      }
    }
    .frame(minHeight: 48)
  }
  
  @ViewBuilder
  var rightOutsideButton: some View {
    ZStack {
      if [.isRecordingTap, .isRecordingHold].contains(state) {
        RecordIndicator()
          .viewSize(80)
          .foregroundColor(theme.colors.recordIndicator)
      }
      Group {
        if state.canSend || availableInput == .textOnly {
          sendButton
            .disabled(!state.canSend)
        } else {
          recordButton
            .highPriorityGesture(dragGesture())
        }
      }
      .compositingGroup()
      .overlay(alignment: .top) {
        Group {
          if state == .isRecordingTap {
            stopRecordButton
          } else if state == .isRecordingHold {
            lockRecordButton
          }
        }
        .sizeGetter($overlaySize)
        // hardcode 28 for now because sizeGetter returns 0 somehow
        .offset(y: (state == .isRecordingTap ? -28 : -overlaySize.height) - 24)
      }
    }
    .viewSize(48)
  }
  
  @ViewBuilder
  var viewOnTop: some View {
    if let message = viewModel.attachments.replyMessage {
      VStack(spacing: 8) {
        Rectangle()
          .foregroundColor(SKStyleAsset.constantSlate.swiftUIColor.opacity(0.6))
          .frame(height: 1)
        
        HStack(alignment: .center) {
          theme.images.reply.replyToMessage
            .resizable()
            .renderingMode(.template)
            .foregroundColor(SKStyleAsset.constantAzure.swiftUIColor)
            .aspectRatio(contentMode: .fit)
            .frame(width: .s6, height: .s6)
          
          Capsule()
            .foregroundColor(SKStyleAsset.constantAzure.swiftUIColor)
            .frame(width: 2)
          
          VStack(alignment: .leading) {
            Text("\(ExyteChatStrings.inputReplyTitle):")
              .font(.fancy.text.regular)
              .foregroundColor(SKStyleAsset.constantAzure.swiftUIColor)
            
            if !message.text.isEmpty {
              textView(message.text)
                .font(.fancy.constant.b3)
                .lineLimit(1)
                .foregroundColor(theme.colors.replyToText)
            }
          }
          .padding(.vertical, 2)
          
          Spacer()
          
          if let first = message.attachments.first {
            AsyncImageView(url: first.thumbnail)
              .viewSize(30)
              .cornerRadius(4)
              .padding(.trailing, 16)
          }
          
          if let _ = message.recording {
            theme.images.inputView.microphone
              .renderingMode(.template)
              .foregroundColor(theme.colors.recordingMicrophone)
          }
          
          theme.images.mediaPicker.cross
            .resizable()
            .renderingMode(.template)
            .foregroundColor(SKStyleAsset.constantAzure.swiftUIColor)
            .aspectRatio(contentMode: .fit)
            .frame(height: 24)
            .onTapGesture {
              viewModel.attachments.replyMessage = nil
            }
        }
        .padding(.horizontal, 26)
      }
      .fixedSize(horizontal: false, vertical: true)
    }
  }
  
  @ViewBuilder
  func textView(_ text: String) -> some View {
    if messageUseMarkdown,
       let attributed = try? AttributedString(markdown: text) {
      Text(attributed)
    } else {
      Text(text)
    }
  }
  
  var attachButton: some View {
    Button {
      onAction(.photo)
    } label: {
      theme.images.inputView.attach
        .viewSize(24)
        .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 8))
    }
  }
  
  var addButton: some View {
    Button {
      onAction(.add)
    } label: {
      theme.images.inputView.add
        .viewSize(24)
        .circleBackground(theme.colors.addButtonBackground)
        .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 8))
    }
  }
  
  var cameraButton: some View {
    Button {
      onAction(.camera)
    } label: {
      theme.images.inputView.attachCamera
        .viewSize(24)
        .padding(EdgeInsets(top: 12, leading: 8, bottom: 12, trailing: 12))
    }
  }
  
  var sendButton: some View {
    Button(action: {
      onAction(.send)
    }) {
      theme.images.inputView.arrowSend
        .viewSize(.s10)
        .circleBackground(state.canSend ? theme.colors.sendButtonBackground : SKStyleAsset.constantSlate.swiftUIColor)
    }
    .disabled(!state.canSend)
  }
  
  var recordButton: some View {
    theme.images.inputView.microphone
      .viewSize(.s10)
      .circleBackground(theme.colors.recordButtonBackground)
      .frameGetter($recordButtonFrame)
  }
  
  var deleteRecordButton: some View {
    Button {
      onAction(.deleteRecord)
    } label: {
      theme.images.recordAudio.deleteRecord
        .resizable()
        .renderingMode(.template)
        .foregroundColor(SKStyleAsset.constantRuby.swiftUIColor)
        .aspectRatio(contentMode: .fit)
        .viewSize(.s5)
        .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 8))
    }
    .frameGetter($deleteRecordFrame)
  }
  
  var stopRecordButton: some View {
    Button {
      onAction(.stopRecordAudio)
    } label: {
      theme.images.recordAudio.stopRecord
        .renderingMode(.template)
        .viewSize(28)
        .foregroundColor(SKStyleAsset.constantOnyx.swiftUIColor)
      
        .background(
          Capsule()
            .fill(SKStyleAsset.componentSlateMessageBG.swiftUIColor)
            .shadow(color: .black.opacity(0.4), radius: 1)
        )
    }
  }
  
  var lockRecordButton: some View {
    Button {
      onAction(.recordAudioLock)
    } label: {
      VStack(spacing: 20) {
        theme.images.recordAudio.lockRecord
          .resizable()
          .renderingMode(.template)
          .foregroundColor(SKStyleAsset.constantOnyx.swiftUIColor)
          .aspectRatio(contentMode: .fit)
          .frame(height: .s4)
        
        theme.images.recordAudio.sendRecord
          .resizable()
          .renderingMode(.template)
          .foregroundColor(SKStyleAsset.constantOnyx.swiftUIColor)
          .aspectRatio(contentMode: .fit)
          .frame(height: .s4)
      }
      .frame(width: 28)
      .padding(.vertical, 16)
      .background(
        Capsule()
          .fill(SKStyleAsset.componentSlateMessageBG.swiftUIColor)
          .shadow(color: .black.opacity(0.4), radius: 1)
      )
    }
    .frameGetter($lockRecordFrame)
  }
  
  var swipeToCancel: some View {
    HStack {
      Spacer()
      Button {
        onAction(.deleteRecord)
      } label: {
        HStack {
          theme.images.recordAudio.cancelRecord
            .resizable()
            .renderingMode(.template)
            .foregroundColor(SKStyleAsset.constantRuby.swiftUIColor)
            .aspectRatio(contentMode: .fit)
            .frame(height: .s3)
          
          Text(ExyteChatStrings.inputCancelTitle)
            .font(.footnote)
            .foregroundColor(SKStyleAsset.constantRuby.swiftUIColor)
        }
      }
      Spacer()
    }
  }
  
  var recordingInProgress: some View {
    HStack {
      Spacer()
      Text("\(ExyteChatStrings.inputRecordingTitle)...")
        .font(.footnote)
        .foregroundColor(SKStyleAsset.constantSlate.swiftUIColor)
      Spacer()
    }
  }
  
  var recordDurationInProcess: some View {
    HStack {
      Circle()
        .foregroundColor(SKStyleAsset.constantRuby.swiftUIColor)
        .viewSize(6)
      recordDuration
    }
  }
  
  var recordDuration: some View {
    Text(DateFormatter.timeString(Int(viewModel.attachments.recording?.duration ?? 0)))
      .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
      .opacity(0.8)
      .font(.caption2)
      .monospacedDigit()
      .padding(.trailing, 12)
  }
  
  var recordDurationLeft: some View {
    Text(DateFormatter.timeString(Int(recordingPlayer.secondsLeft)))
      .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
      .opacity(0.8)
      .font(.caption2)
      .monospacedDigit()
      .padding(.trailing, 12)
  }
  
  var playRecordButton: some View {
    Button {
      onAction(.playRecord)
    } label: {
      theme.images.recordAudio.playRecord
        .resizable()
        .renderingMode(.template)
        .foregroundColor(SKStyleAsset.constantAzure.swiftUIColor)
        .aspectRatio(contentMode: .fit)
        .frame(height: .s6)
    }
  }
  
  var pauseRecordButton: some View {
    Button {
      onAction(.pauseRecord)
    } label: {
      theme.images.recordAudio.pauseRecord
        .resizable()
        .renderingMode(.template)
        .foregroundColor(SKStyleAsset.constantAzure.swiftUIColor)
        .aspectRatio(contentMode: .fit)
        .frame(height: .s6)
    }
  }
  
  @ViewBuilder
  var recordWaveform: some View {
    if let samples = viewModel.attachments.recording?.waveformSamples {
      HStack(spacing: 8) {
        Group {
          if state == .hasRecording || state == .pausedRecording {
            playRecordButton
          } else if state == .playingRecording {
            pauseRecordButton
          }
        }
        .frame(width: 20)
        
        RecordWaveformPlaying(
          samples: samples,
          progress: recordingPlayer.progress,
          color: SKStyleAsset.constantAzure.swiftUIColor,
          addExtraDots: true
        )
      }
      .padding(.horizontal, 8)
    }
  }
  
  var fieldBackgroundColor: Color {
    switch style {
    case .message:
      return theme.colors.inputMessageBackground
    case .signature:
      return theme.colors.inputSignatureBackground
    }
  }
  
  var backgroundColor: Color {
    switch style {
    case .message:
      return theme.colors.mainBackground
    case .signature:
      return SKStyleAsset.onyx.swiftUIColor
    }
  }
  
  func dragGesture() -> some Gesture {
    DragGesture(minimumDistance: 0.0, coordinateSpace: .global)
      .onChanged { value in
        if dragStart == nil {
          dragStart = Date()
          cancelGesture = false
          tapDelayTimer = Timer.scheduledTimer(withTimeInterval: tapDelay, repeats: false) { _ in
            if state != .isRecordingTap, state != .waitingForRecordingPermission {
              self.onAction(.recordAudioHold)
            }
          }
        }
        
        if value.location.y < lockRecordFrame.minY,
           value.location.x > recordButtonFrame.minX {
          cancelGesture = true
          onAction(.recordAudioLock)
        }
        
        if value.location.x < UIScreen.main.bounds.width/2,
           value.location.y > recordButtonFrame.minY {
          cancelGesture = true
          onAction(.deleteRecord)
        }
      }
      .onEnded() { value in
        if !cancelGesture {
          tapDelayTimer = nil
          if recordButtonFrame.contains(value.location) {
            if let dragStart = dragStart, Date().timeIntervalSince(dragStart) < tapDelay {
              onAction(.recordAudioTap)
            } else if state != .waitingForRecordingPermission {
              onAction(.send)
            }
          }
          else if lockRecordFrame.contains(value.location) {
            onAction(.recordAudioLock)
          }
          else if deleteRecordFrame.contains(value.location) {
            onAction(.deleteRecord)
          } else {
            onAction(.send)
          }
        }
        dragStart = nil
      }
  }
}
