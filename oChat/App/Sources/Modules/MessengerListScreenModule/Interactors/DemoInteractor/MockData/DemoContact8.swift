//
//  DemoContact8.swift
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
  func createMessengesModel8() -> [String: [MessengeModel]] {
    [
      toxAddress: [
        .init(
          messageType: .received,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact8.Received._1,
          replyMessageText: nil,
          images: [],
          videos: [],
          recording: nil
        ),
        .init(
          messageType: .own,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact8.Own._1,
          replyMessageText: nil,
          images: [],
          videos: [],
          recording: nil
        ),
        .init(
          messageType: .received,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact8.Received._2,
          replyMessageText: nil,
          images: [],
          videos: [],
          recording: nil
        ),
        .init(
          messageType: .own,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact8.Own._2,
          replyMessageText: nil,
          images: [],
          videos: [],
          recording: nil
        ),
        .init(
          messageType: .received,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact8.Received._3,
          replyMessageText: nil,
          images: [],
          videos: [],
          recording: nil
        ),
        .init(
          messageType: .own,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact8.Own._3,
          replyMessageText: nil,
          images: [],
          videos: [],
          recording: nil
        ),
        .init(
          messageType: .received,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact8.Received._4,
          replyMessageText: nil,
          images: [],
          videos: [],
          recording: nil
        )
      ]
    ]
  }
  
  func createDemoContactModel8() -> ContactModel {
    return ContactModel(
      id: toxAddress,
      dateOfCreation: Date().addingTimeInterval(8),
      name: nil,
      toxAddress: toxAddress,
      meshAddress: nil,
      status: .offline,
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

private let toxAddress = "24e04409b4b86cc34dea2e549ae78e0c99f4ae08baa4c14bfec088c5e3b2db2693ec7b22258b"
// swiftlint:enable all
