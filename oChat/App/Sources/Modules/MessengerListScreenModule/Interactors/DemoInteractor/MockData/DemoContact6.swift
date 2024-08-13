//
//  DemoContact6.swift
//  oChat
//
//  Created by Vitalii Sosin on 03.08.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SwiftUI
import SKAbstractions
import SKStyle
import AVFoundation
import SKManagers

// MARK: - DemoContactModel

// swiftlint:disable all
extension MessengerListScreenModuleDemoInteractor {
  func createMessengesModel6() -> [String: [MessengeModel]] {
    [
      toxAddress: [
        .init(
          messageType: .received,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact6.Received._1,
          replyMessageText: nil,
          images: [],
          videos: [],
          recording: nil
        ),
        .init(
          messageType: .own,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact6.Own._1,
          replyMessageText: nil,
          images: [],
          videos: [],
          recording: nil
        ),
        .init(
          messageType: .received,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact6.Received._2,
          replyMessageText: nil,
          images: [],
          videos: [],
          recording: nil
        ),
        .init(
          messageType: .own,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact6.Own._2,
          replyMessageText: nil,
          images: [],
          videos: [],
          recording: nil
        ),
        .init(
          messageType: .received,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact6.Received._3,
          replyMessageText: nil,
          images: [],
          videos: [],
          recording: nil
        ),
        .init(
          messageType: .own,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact6.Own._3,
          replyMessageText: nil,
          images: [],
          videos: [],
          recording: nil
        ),
        .init(
          messageType: .received,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact6.Received._4,
          replyMessageText: nil,
          images: [],
          videos: [],
          recording: nil
        )
      ]
    ]
  }
  
  func createDemoContactModel6() -> ContactModel {
    return ContactModel(
      id: toxAddress,
      dateOfCreation: Date().addingTimeInterval(6),
      name: nil,
      toxAddress: toxAddress,
      meshAddress: nil,
      status: .online,
      encryptionPublicKey: toxAddress,
      toxPublicKey: toxAddress,
      pushNotificationToken: nil,
      isNewMessagesAvailable: false,
      isTyping: true,
      canSaveMedia: true,
      isChatHistoryStored: true
    )
  }
}

private let toxAddress = "ac3b05d568d26079359381422a887e32d8d2a053fa4957f30b199e338982fa16e8cd3935a353"
// swiftlint:enable all
