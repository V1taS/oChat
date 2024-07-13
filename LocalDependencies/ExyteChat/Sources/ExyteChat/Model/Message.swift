//
//  Message.swift
//  Chat
//
//  Created by Sosin Vitalii on 20.04.2022.
//

import SwiftUI

public struct Message: Identifiable, Hashable {
  public var id: String
  public var user: User
  public var status: Status
  public var createdAt: Date
  public var isSystemMessage: Bool
  
  public var text: String
  public var attachments: [Attachment]
  public var recording: Recording?
  public var replyMessage: ReplyMessage?
  
  public var retryAction: ((Message) -> Void)?
  public var deleteAction: ((Message) -> Void)?
  public var copyAction: ((Message) -> Void)?
  
  public init(
    id: String,
    user: User,
    status: Status,
    createdAt: Date = Date(),
    isSystemMessage: Bool,
    text: String = "",
    attachments: [Attachment] = [],
    recording: Recording? = nil,
    replyMessage: ReplyMessage? = nil,
    retryAction: ((Message) -> Void)? = nil,
    deleteAction: ((Message) -> Void)? = nil,
    copyAction: ((Message) -> Void)? = nil
  ) {
    self.id = id
    self.user = user
    self.status = status
    self.createdAt = createdAt
    self.isSystemMessage = isSystemMessage
    self.text = text
    self.attachments = attachments
    self.recording = recording
    self.replyMessage = replyMessage
    self.retryAction = retryAction
    self.deleteAction = deleteAction
    self.copyAction = copyAction
  }
  
  public static func makeMessage(
    id: String,
    user: User,
    status: Status,
    draft: DraftMessage) async -> Message {
      let attachments = await draft.medias.asyncCompactMap { media -> Attachment? in
        guard let thumbnailURL = await media.getThumbnailURL() else {
          return nil
        }
        
        switch media.type {
        case .image:
          return Attachment(id: UUID().uuidString, url: thumbnailURL, type: .image)
        case .video:
          guard let fullURL = await media.getURL() else {
            return nil
          }
          return Attachment(id: UUID().uuidString, thumbnail: thumbnailURL, full: fullURL, type: .video)
        }
      }
      
      return Message(
        id: id,
        user: user,
        status: status,
        createdAt: draft.createdAt,
        isSystemMessage: false,
        text: draft.text,
        attachments: attachments,
        recording: draft.recording,
        replyMessage: draft.replyMessage
      )
    }
}

public extension Message {
  public enum Status: Equatable, Hashable {
    case sending
    case sent
    case read
    case error
    
    public func hash(into hasher: inout Hasher) {
      switch self {
      case .sending:
        return hasher.combine("sending")
      case .sent:
        return hasher.combine("sent")
      case .read:
        return hasher.combine("read")
      case .error:
        return hasher.combine("error")
      }
    }
    
    public static func == (lhs: Message.Status, rhs: Message.Status) -> Bool {
      switch (lhs, rhs) {
      case (.sending, .sending):
        return true
      case (.sent, .sent):
        return true
      case (.read, .read):
        return true
      case ( .error, .error):
        return true
      default:
        return false
      }
    }
  }
}

extension Message {
  var time: String {
    DateFormatter.timeFormatter.string(from: createdAt)
  }
}

extension Message: Equatable {}

public struct Recording: Codable, Hashable {
  public var duration: Double
  public var waveformSamples: [CGFloat]
  public var url: URL?
  
  public init(duration: Double = 0.0, waveformSamples: [CGFloat] = [], url: URL? = nil) {
    self.duration = duration
    self.waveformSamples = waveformSamples
    self.url = url
  }
}

public struct ReplyMessage: Codable, Identifiable, Hashable {
  public static func == (lhs: ReplyMessage, rhs: ReplyMessage) -> Bool {
    lhs.id == rhs.id
  }
  
  public var id: String
  public var user: User
  
  public var text: String
  public var attachments: [Attachment]
  public var recording: Recording?
  
  public init(id: String,
              user: User,
              text: String = "",
              attachments: [Attachment] = [],
              recording: Recording? = nil) {
    
    self.id = id
    self.user = user
    self.text = text
    self.attachments = attachments
    self.recording = recording
  }
  
  func toMessage() -> Message {
    Message(
      id: id,
      user: user,
      status: .sending,
      isSystemMessage: false, 
      text: text,
      attachments: attachments,
      recording: recording
    )
  }
}

public extension Message {
  func toReplyMessage() -> ReplyMessage {
    ReplyMessage(id: id, user: user, text: text, attachments: attachments, recording: recording)
  }
}

public extension Message {
  public static func ==(lhs: Message, rhs: Message) -> Bool {
      return lhs.id == rhs.id &&
          lhs.user == rhs.user &&
          lhs.status == rhs.status &&
          lhs.createdAt == rhs.createdAt &&
          lhs.text == rhs.text &&
          lhs.attachments == rhs.attachments &&
          lhs.recording == rhs.recording &&
          lhs.replyMessage == rhs.replyMessage
  }
  
  public func hash(into hasher: inout Hasher) {
      hasher.combine(id)
      hasher.combine(user)
      hasher.combine(status)
      hasher.combine(createdAt)
      hasher.combine(text)
      hasher.combine(attachments)
      hasher.combine(recording)
      hasher.combine(replyMessage)
  }
}
