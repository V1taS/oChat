//
//  DemoContact10.swift
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
  func createMessengesModel10() -> [String: [MessengeModel]] {
    [
      toxAddress: [
        .init(
          messageType: .received,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact10.Received._1,
          replyMessageText: nil,
          images: [],
          videos: [],
          recording: nil
        ),
        .init(
          messageType: .own,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact10.Own._1,
          replyMessageText: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact10.Received._1,
          images: [],
          videos: [],
          recording: nil
        ),
        .init(
          messageType: .received,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact10.Received._2,
          replyMessageText: nil,
          images: [],
          videos: [],
          recording: nil
        ),
        .init(
          messageType: .own,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact10.Own._2,
          replyMessageText: nil,
          images: [],
          videos: [],
          recording: nil
        ),
        .init(
          messageType: .received,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact10.Received._3,
          replyMessageText: nil,
          images: [],
          videos: [],
          recording: nil
        ),
        .init(
          messageType: .own,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact10.Own._3,
          replyMessageText: nil,
          images: [],
          videos: [],
          recording: nil
        ),
        .init(
          messageType: .received,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact10.Received._4,
          replyMessageText: nil,
          images: [],
          videos: [],
          recording: nil
        )
      ]
    ]
  }
  
  func createDemoContactModel10() -> ContactModel {
    return ContactModel(
      id: toxAddress,
      dateOfCreation: Date().addingTimeInterval(10),
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

private let toxAddress = "3408e59993b53337da5fe462c46765a297e0409cedfa21cd30f40686fabd6e2866ddefaade30"
// swiftlint:enable all
