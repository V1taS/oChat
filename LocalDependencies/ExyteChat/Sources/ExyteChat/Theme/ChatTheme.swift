//
//  ChatTheme.swift
//
//
//  Created by Sosin Vitalii on 31.01.2023.
//

import SwiftUI
import SKStyle

struct ChatThemeKey: EnvironmentKey {
  static var defaultValue: ChatTheme = ChatTheme()
}

extension EnvironmentValues {
  var chatTheme: ChatTheme {
    get { self[ChatThemeKey.self] }
    set { self[ChatThemeKey.self] = newValue }
  }
}

public extension View {
  func chatTheme(_ theme: ChatTheme) -> some View {
    self.environment(\.chatTheme, theme)
  }
  
  func chatTheme(colors: ChatTheme.Colors = .init(),
                 images: ChatTheme.Images = .init()) -> some View {
    self.environment(\.chatTheme, ChatTheme(colors: colors, images: images))
  }
}

// MARK: - ChatTheme

public struct ChatTheme {
  public let colors: ChatTheme.Colors
  public let images: ChatTheme.Images
  
  public init(colors: ChatTheme.Colors = .init(),
              images: ChatTheme.Images = .init()) {
    self.colors = colors
    self.images = images
  }
}

// MARK: - Images

extension ChatTheme {
  public struct Images {
    public struct AttachMenu {
      public var camera: Image
      public var contact: Image
      public var document: Image
      public var location: Image
      public var photo: Image
      public var pickDocument: Image
      public var pickLocation: Image
      public var pickPhoto: Image
    }
    
    public struct InputView {
      public var add: Image
      public var arrowSend: Image
      public var attach: Image
      public var attachCamera: Image
      public var microphone: Image
    }
    
    public struct FullscreenMedia {
      public var play: Image
      public var pause: Image
      public var mute: Image
      public var unmute: Image
    }
    
    public struct MediaPicker {
      public var chevronDown: Image
      public var chevronRight: Image
      public var cross: Image
      public var save: Image
    }
    
    public struct Message {
      public var attachedDocument: Image
      public var checkmarks: Image
      public var error: Image
      public var muteVideo: Image
      public var pauseAudio: Image
      public var pauseVideo: Image
      public var playAudio: Image
      public var playVideo: Image
      public var sending: Image
    }
    
    public struct MessageMenu {
      public var delete: Image
      public var edit: Image
      public var forward: Image
      public var reply: Image
      public var retry: Image
      public var save: Image
      public var select: Image
    }
    
    public struct RecordAudio {
      public var cancelRecord: Image
      public var deleteRecord: Image
      public var lockRecord: Image
      public var pauseRecord: Image
      public var playRecord: Image
      public var sendRecord: Image
      public var stopRecord: Image
    }
    
    public struct Reply {
      public var cancelReply: Image
      public var replyToMessage: Image
    }
    
    public var backButton: Image
    public var scrollToBottom: Image
    
    public var attachMenu: AttachMenu
    public var inputView: InputView
    public var fullscreenMedia: FullscreenMedia
    public var mediaPicker: MediaPicker
    public var message: Message
    public var messageMenu: MessageMenu
    public var recordAudio: RecordAudio
    public var reply: Reply
    
    public init(
      camera: Image? = nil,
      contact: Image? = nil,
      document: Image? = nil,
      location: Image? = nil,
      photo: Image? = nil,
      pickDocument: Image? = nil,
      pickLocation: Image? = nil,
      pickPhoto: Image? = nil,
      add: Image? = nil,
      arrowSend: Image? = nil,
      attach: Image? = nil,
      attachCamera: Image? = nil,
      microphone: Image? = nil,
      fullscreenPlay: Image? = nil,
      fullscreenPause: Image? = nil,
      fullscreenMute: Image? = nil,
      fullscreenUnmute: Image? = nil,
      chevronDown: Image? = nil,
      chevronRight: Image? = nil,
      cross: Image? = nil,
      save: Image? = nil,
      attachedDocument: Image? = nil,
      checkmarks: Image? = nil,
      error: Image? = nil,
      muteVideo: Image? = nil,
      pauseAudio: Image? = nil,
      pauseVideo: Image? = nil,
      playAudio: Image? = nil,
      playVideo: Image? = nil,
      sending: Image? = nil,
      delete: Image? = nil,
      edit: Image? = nil,
      forward: Image? = nil,
      reply: Image? = nil,
      retry: Image? = nil,
      select: Image? = nil,
      cancelRecord: Image? = nil,
      deleteRecord: Image? = nil,
      lockRecord: Image? = nil,
      pauseRecord: Image? = nil,
      playRecord: Image? = nil,
      sendRecord: Image? = nil,
      stopRecord: Image? = nil,
      cancelReply: Image? = nil,
      replyToMessage: Image? = nil,
      backButton: Image? = nil,
      scrollToBottom: Image? = nil
    ) {
      self.backButton = backButton ?? Image("backArrow", bundle: .current)
      self.scrollToBottom = scrollToBottom ?? Image("scrollToBottom", bundle: .current)
      
      self.attachMenu = AttachMenu(
        camera: camera ?? Image("camera", bundle: .current),
        contact: contact ?? Image("contact", bundle: .current),
        document: document ?? Image("document", bundle: .current),
        location: location ?? Image("location", bundle: .current),
        photo: photo ?? Image("photo", bundle: .current),
        pickDocument: pickDocument ?? Image("pickDocument", bundle: .current),
        pickLocation: pickLocation ?? Image("pickLocation", bundle: .current),
        pickPhoto: pickPhoto ?? Image("pickPhoto", bundle: .current)
      )
      
      self.inputView = InputView(
        add: add ?? Image("add", bundle: .current),
        arrowSend: arrowSend ?? Image("arrowSend", bundle: .current),
        attach: attach ?? Image("attach", bundle: .current),
        attachCamera: attachCamera ?? Image("attachCamera", bundle: .current),
        microphone: microphone ?? Image("microphone", bundle: .current)
      )
      
      self.fullscreenMedia = FullscreenMedia(
        play: fullscreenPlay ?? Image(systemName: "play.fill"),
        pause: fullscreenPause ?? Image(systemName: "pause.fill"),
        mute: fullscreenMute ?? Image(systemName: "speaker.slash.fill"),
        unmute: fullscreenUnmute ?? Image(systemName: "speaker.fill")
      )
      
      self.mediaPicker = MediaPicker(
        chevronDown: chevronDown ?? Image("chevronDown", bundle: .current),
        chevronRight: chevronRight ?? Image("chevronRight", bundle: .current),
        cross: cross ?? Image("cross", bundle: .current), 
        save: save ?? Image("save", bundle: .current)
      )
      
      self.message = Message(
        attachedDocument: attachedDocument ?? Image("attachedDocument", bundle: .current),
        checkmarks: checkmarks ?? Image("checkmarks", bundle: .current),
        error: error ?? Image("error", bundle: .current),
        muteVideo: muteVideo ?? Image("muteVideo", bundle: .current),
        pauseAudio: pauseAudio ?? Image("pauseAudio", bundle: .current),
        pauseVideo: pauseVideo ?? Image(systemName: "pause.circle.fill"),
        playAudio: playAudio ?? Image("playAudio", bundle: .current),
        playVideo: playVideo ?? Image(systemName: "play.circle.fill"),
        sending: sending ?? Image("sending", bundle: .current)
      )
      
      self.messageMenu = MessageMenu(
        delete: delete ?? Image("delete", bundle: .current),
        edit: edit ?? Image("edit", bundle: .current),
        forward: forward ?? Image("forward", bundle: .current),
        reply: reply ?? Image("reply", bundle: .current),
        retry: retry ?? Image("retry", bundle: .current),
        save: save ?? Image("save", bundle: .current),
        select: select ?? Image("select", bundle: .current)
      )
      
      self.recordAudio = RecordAudio(
        cancelRecord: cancelRecord ?? Image("cancelRecord", bundle: .current),
        deleteRecord: deleteRecord ?? Image("deleteRecord", bundle: .current),
        lockRecord: lockRecord ?? Image("lockRecord", bundle: .current),
        pauseRecord: pauseRecord ?? Image("pauseRecord", bundle: .current),
        playRecord: playRecord ?? Image("playRecord", bundle: .current),
        sendRecord: sendRecord ?? Image("sendRecord", bundle: .current),
        stopRecord: stopRecord ?? Image("stopRecord", bundle: .current)
      )
      
      self.reply = Reply(
        cancelReply: cancelReply ?? Image("cancelReply", bundle: .current),
        replyToMessage: replyToMessage ?? Image("replyToMessage", bundle: .current)
      )
    }
  }
}

// MARK: - Colors

extension ChatTheme {
  public struct Colors {
    // Сообщения
    public var messageStatus: Color
    public var messageReadStatus: Color
    public var messageErrorStatus: Color
    public var myMessageBubbleBackground: Color
    public var friendMessageBubbleBackground: Color
    public var myMessageBubbleText: Color
    public var friendMessageBubbleText: Color
    public var myMessageTime: Color
    public var friendMessageTime: Color
    
    // Ввод сообщений
    public var inputMessageBackground: Color
    public var inputSignatureBackground: Color
    public var inputPlaceholder: Color
    public var inputText: Color
    
    // Ответы на сообщения
    public var replyToUser: Color
    public var replySeparator: Color
    public var replyToText: Color
    public var cancelText: Color
    
    // Запись сообщений
    public var recordingMicrophone: Color
    public var recordButtonBackground: Color
    public var recordIndicator: Color
    public var recordWaveFormOwn: Color
    public var recordWaveFormReceived: Color
    public var recordWaveFormColorButtonOwn: Color
    public var recordWaveFormColorButtonReceived: Color
    public var recordWaveFormColorButtonBgOwn: Color
    public var recordWaveFormColorButtonBgReceived: Color
    public var recordDot: Color
    public var recordDurationText: Color
    public var recordDurationLeftText: Color
    public var recordWaveformPlayingText: Color
    public var recordingText: Color
    
    // Медиа и вложения
    public var attachmentImage: Color
    public var attachmentCellStroke: Color
    public var textMediaPicker: Color
    
    // Основные элементы интерфейса
    public var mainBackground: Color
    public var addButtonBackground: Color
    public var sendButtonBackground: Color
    public var menuButtonBackground: Color
    public var menuButtonText: Color
    public var circleScrolledButtonBackground: Color
    public var activityIndicator: Color
    
    // Вспомогательные элементы интерфейса
    public var infoToolStatusItem: Color
    public var infoToolTextItem: Color
    public var infoToolItemBackground: Color
    
    // Time Capsule
    public var timeCapsuleBackground: Color
    public var timeCapsuleForeground: Color
    
    /**
     Инициализатор структуры Colors
     
     - Параметры:
     - messageStatus: Цвет статуса сообщения.
     - messageReadStatus: Цвет статуса прочтения сообщения.
     - messageErrorStatus: Цвет статуса ошибки сообщения.
     - myMessageBubbleBackground: Цвет фона пузыря моего сообщения.
     - friendMessageBubbleBackground: Цвет фона пузыря сообщения друга.
     - myMessageBubbleText: Цвет текста в моем сообщении.
     - friendMessageBubbleText: Цвет текста в сообщении друга.
     - myMessageTime: Цвет времени моего сообщения.
     - friendMessageTime: Цвет времени сообщения друга.
     - inputMessageBackground: Цвет фона ввода сообщения.
     - inputSignatureBackground: Цвет фона подписи ввода.
     - inputPlaceholder: Цвет плейсхолдера ввода.
     - inputText: Цвет текста ввода.
     - replyToUser: Цвет текста при ответе пользователю.
     - replySeparator: Цвет разделителя при ответе.
     - replyToText: Цвет текста при ответе.
     - cancelText: Цвет текста отмены.
     - recordingMicrophone: Цвет иконки микрофона при записи.
     - recordButtonBackground: Цвет фона кнопки записи.
     - recordIndicator: Цвет индикатора записи.
     - recordWaveFormOwn: Цвет формы волны записи (собственной).
     - recordWaveFormReceived: Цвет формы волны записи (полученной).
     - recordWaveFormColorButtonOwn: Цвет кнопки формы волны (собственной).
     - recordWaveFormColorButtonReceived: Цвет кнопки формы волны (полученной).
     - recordWaveFormColorButtonBgOwn: Цвет фона кнопки формы волны (собственной).
     - recordWaveFormColorButtonBgReceived: Цвет фона кнопки формы волны (полученной).
     - recordDot: Цвет точки записи.
     - recordDurationText: Цвет текста длительности записи.
     - recordDurationLeftText: Цвет текста оставшегося времени записи.
     - recordWaveformPlayingText: Цвет текста воспроизведения формы волны.
     - recordingText: Цвет текста записи.
     - attachmentImage: Цвет изображения вложения.
     - attachmentCellStroke: Цвет обводки ячейки вложения.
     - textMediaPicker: Цвет текста медиапикера.
     - mainBackground: Цвет основного фона.
     - addButtonBackground: Цвет фона кнопки добавления.
     - sendButtonBackground: Цвет фона кнопки отправки.
     - menuButtonBackground: Цвет фона кнопки меню.
     - menuButtonText: Цвет текста кнопки меню.
     - circleScrolledButtonBackground: Цвет фона кнопки скролла.
     - activityIndicator: Цвет индикатора активности.
     - infoToolStatusItem: Цвет элемента статуса информационного инструмента.
     - infoToolTextItem: Цвет текста элемента информационного инструмента.
     - infoToolItemBackground: Цвет фона элемента информационного инструмента.
     - timeCapsuleBackground: Цвет фона таймкапсулы.
     - timeCapsuleForeground: Цвет переднего плана таймкапсулы.
     */
    public init(
      messageStatus: Color = SKStyleAsset.constantSlate.swiftUIColor,
      messageReadStatus: Color = SKStyleAsset.constantAzure.swiftUIColor,
      messageErrorStatus: Color = SKStyleAsset.constantRuby.swiftUIColor,
      myMessageBubbleBackground: Color = SKStyleAsset.constantAzure.swiftUIColor,
      friendMessageBubbleBackground: Color = SKStyleAsset.componentSlateMessageBG.swiftUIColor,
      myMessageBubbleText: Color = SKStyleAsset.constantGhost.swiftUIColor,
      friendMessageBubbleText: Color = SKStyleAsset.constantNavy.swiftUIColor,
      myMessageTime: Color = SKStyleAsset.constantGhost.swiftUIColor.opacity(0.4),
      friendMessageTime: Color = SKStyleAsset.constantNavy.swiftUIColor.opacity(0.4),
      inputMessageBackground: Color = SKStyleAsset.navy.swiftUIColor,
      inputSignatureBackground: Color = SKStyleAsset.navy.swiftUIColor,
      inputPlaceholder: Color = SKStyleAsset.constantSlate.swiftUIColor,
      inputText: Color = SKStyleAsset.ghost.swiftUIColor,
      replyToUser: Color = SKStyleAsset.constantSlate.swiftUIColor,
      replySeparator: Color = SKStyleAsset.constantSlate.swiftUIColor,
      replyToText: Color = SKStyleAsset.constantNavy.swiftUIColor,
      cancelText: Color = SKStyleAsset.constantNavy.swiftUIColor,
      recordingMicrophone: Color = SKStyleAsset.constantSlate.swiftUIColor,
      recordButtonBackground: Color = SKStyleAsset.constantAzure.swiftUIColor,
      recordIndicator: Color = SKStyleAsset.constantAzure.swiftUIColor,
      recordWaveFormOwn: Color = SKStyleAsset.constantSlate.swiftUIColor,
      recordWaveFormReceived: Color = SKStyleAsset.constantGhost.swiftUIColor,
      recordWaveFormColorButtonOwn: Color = SKStyleAsset.constantAzure.swiftUIColor,
      recordWaveFormColorButtonReceived: Color = SKStyleAsset.constantSlate.swiftUIColor,
      recordWaveFormColorButtonBgOwn: Color = SKStyleAsset.constantSlate.swiftUIColor,
      recordWaveFormColorButtonBgReceived: Color = SKStyleAsset.constantAzure.swiftUIColor,
      recordDot: Color = SKStyleAsset.constantRuby.swiftUIColor,
      recordDurationText: Color = SKStyleAsset.constantSlate.swiftUIColor,
      recordDurationLeftText: Color = SKStyleAsset.constantSlate.swiftUIColor,
      recordWaveformPlayingText: Color = SKStyleAsset.constantSlate.swiftUIColor,
      recordingText: Color = SKStyleAsset.constantSlate.swiftUIColor,
      attachmentImage: Color = SKStyleAsset.constantLightMistGray.swiftUIColor,
      attachmentCellStroke: Color = SKStyleAsset.constantLightMistGray.swiftUIColor,
      textMediaPicker: Color = SKStyleAsset.ghost.swiftUIColor,
      mainBackground: Color = SKStyleAsset.onyx.swiftUIColor,
      addButtonBackground: Color = SKStyleAsset.constantAzure.swiftUIColor,
      sendButtonBackground: Color = SKStyleAsset.constantAzure.swiftUIColor,
      menuButtonBackground: Color = SKStyleAsset.constantSlate.swiftUIColor,
      menuButtonText: Color = SKStyleAsset.constantOnyx.swiftUIColor,
      circleScrolledButtonBackground: Color = SKStyleAsset.componentSlateMessageBG.swiftUIColor,
      activityIndicator: Color = SKStyleAsset.constantLightMistGray.swiftUIColor,
      infoToolStatusItem: Color = SKStyleAsset.constantLightMistGray.swiftUIColor,
      infoToolTextItem: Color = SKStyleAsset.constantLightMistGray.swiftUIColor,
      infoToolItemBackground: Color = SKStyleAsset.constantAzure.swiftUIColor,
      timeCapsuleBackground: Color = SKStyleAsset.constantLightMistGray.swiftUIColor.opacity(0.4),
      timeCapsuleForeground: Color = SKStyleAsset.constantOnyx.swiftUIColor
    ) {
      self.messageStatus = messageStatus
      self.messageReadStatus = messageReadStatus
      self.messageErrorStatus = messageErrorStatus
      self.myMessageBubbleBackground = myMessageBubbleBackground
      self.friendMessageBubbleBackground = friendMessageBubbleBackground
      self.myMessageBubbleText = myMessageBubbleText
      self.friendMessageBubbleText = friendMessageBubbleText
      self.myMessageTime = myMessageTime
      self.friendMessageTime = friendMessageTime
      self.inputMessageBackground = inputMessageBackground
      self.inputSignatureBackground = inputSignatureBackground
      self.inputPlaceholder = inputPlaceholder
      self.inputText = inputText
      self.replyToUser = replyToUser
      self.replySeparator = replySeparator
      self.replyToText = replyToText
      self.cancelText = cancelText
      self.recordingMicrophone = recordingMicrophone
      self.recordButtonBackground = recordButtonBackground
      self.recordIndicator = recordIndicator
      self.recordWaveFormOwn = recordWaveFormOwn
      self.recordWaveFormReceived = recordWaveFormReceived
      self.recordWaveFormColorButtonOwn = recordWaveFormColorButtonOwn
      self.recordWaveFormColorButtonReceived = recordWaveFormColorButtonReceived
      self.recordWaveFormColorButtonBgOwn = recordWaveFormColorButtonBgOwn
      self.recordWaveFormColorButtonBgReceived = recordWaveFormColorButtonBgReceived
      self.recordDot = recordDot
      self.recordDurationText = recordDurationText
      self.recordDurationLeftText = recordDurationLeftText
      self.recordWaveformPlayingText = recordWaveformPlayingText
      self.recordingText = recordingText
      self.attachmentImage = attachmentImage
      self.attachmentCellStroke = attachmentCellStroke
      self.textMediaPicker = textMediaPicker
      self.mainBackground = mainBackground
      self.addButtonBackground = addButtonBackground
      self.sendButtonBackground = sendButtonBackground
      self.menuButtonBackground = menuButtonBackground
      self.menuButtonText = menuButtonText
      self.circleScrolledButtonBackground = circleScrolledButtonBackground
      self.activityIndicator = activityIndicator
      self.infoToolStatusItem = infoToolStatusItem
      self.infoToolTextItem = infoToolTextItem
      self.infoToolItemBackground = infoToolItemBackground
      self.timeCapsuleBackground = timeCapsuleBackground
      self.timeCapsuleForeground = timeCapsuleForeground
    }
  }
}
