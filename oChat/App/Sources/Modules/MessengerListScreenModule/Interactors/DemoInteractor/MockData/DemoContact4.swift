//
//  DemoContact4.swift
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
  func createMessengesModel4() -> [String: [MessengeModel]] {
    [
      toxAddress: [
        .init(
          messageType: .received,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact4.Received._1,
          replyMessageText: nil,
          images: [],
          videos: [],
          recording: nil
        ),
        .init(
          messageType: .own,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact4.Own._1,
          replyMessageText: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact4.Received._1,
          images: [],
          videos: [],
          recording: nil
        ),
        .init(
          messageType: .received,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact4.Received._2,
          replyMessageText: nil,
          images: [],
          videos: [],
          recording: nil
        ),
        .init(
          messageType: .own,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact4.Own._2,
          replyMessageText: nil,
          images: [],
          videos: [],
          recording: nil
        ),
        .init(
          messageType: .received,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact4.Received._3,
          replyMessageText: nil,
          images: [],
          videos: [],
          recording: nil
        ),
        .init(
          messageType: .own,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact4.Own._3,
          replyMessageText: nil,
          images: [],
          videos: [],
          recording: nil
        ),
        .init(
          messageType: .received,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact4.Received._4,
          replyMessageText: nil,
          images: [],
          videos: [],
          recording: nil
        ),
        .init(
          messageType: .own,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact4.Own._4,
          replyMessageText: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact4.Received._4,
          images: [],
          videos: [],
          recording: nil
        )
      ]
    ]
  }
  
  func createDemoContactModel4() -> ContactModel {
    return ContactModel(
      id: toxAddress,
      dateOfCreation: Date().addingTimeInterval(4),
      name: nil,
      toxAddress: toxAddress,
      meshAddress: nil,
      status: .online,
      encryptionPublicKey: toxAddress,
      toxPublicKey: toxAddress,
      pushNotificationToken: nil,
      isNewMessagesAvailable: true,
      isTyping: true,
      canSaveMedia: true,
      isChatHistoryStored: true
    )
  }
}

private let toxAddress = "021ba7ca11738566ed0ee07619e1d1c5415968db72f1ddd13850422269f91648c8463efa8145"
// swiftlint:enable all
