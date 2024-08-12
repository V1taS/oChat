//
//  DemoContact11.swift
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
  func createMessengesModel11() -> [String: [MessengeModel]] {
    [
      toxAddress: [
        .init(
          messageType: .received,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact11.Received._1,
          replyMessageText: nil,
          images: [],
          videos: [],
          recording: nil
        ),
        .init(
          messageType: .own,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact11.Own._1,
          replyMessageText: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact11.Received._1,
          images: [],
          videos: [],
          recording: nil
        ),
        .init(
          messageType: .received,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact11.Received._2,
          replyMessageText: nil,
          images: [],
          videos: [],
          recording: nil
        ),
        .init(
          messageType: .own,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact11.Own._2,
          replyMessageText: nil,
          images: [],
          videos: [],
          recording: nil
        ),
        .init(
          messageType: .received,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact11.Received._3,
          replyMessageText: nil,
          images: [],
          videos: [],
          recording: nil
        ),
        .init(
          messageType: .own,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact11.Own._3,
          replyMessageText: nil,
          images: [],
          videos: [],
          recording: nil
        ),
        .init(
          messageType: .received,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact11.Received._4,
          replyMessageText: nil,
          images: [],
          videos: [],
          recording: nil
        ),
        .init(
          messageType: .own,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization.Demo
            .Contact11.Own._4,
          replyMessageText: nil,
          images: [],
          videos: [],
          recording: nil
        )
      ]
    ]
  }
  
  func createDemoContactModel11() -> ContactModel {
    return ContactModel(
      id: toxAddress,
      dateOfCreation: Date().addingTimeInterval(11),
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

private let toxAddress = "2c76b9ba955d317784f0567bcc9b03a272588a18985b9535d136e9b8fc82dc611ae829e2f21d"
// swiftlint:enable all
