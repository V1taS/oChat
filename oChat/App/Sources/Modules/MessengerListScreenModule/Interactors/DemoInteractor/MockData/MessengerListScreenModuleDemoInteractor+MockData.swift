//
//  MessengerListScreenModuleDemoInteractor+MockData.swift
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


// MARK: - DemoInteractor

// swiftlint:disable all
extension MessengerListScreenModuleDemoInteractor {
  func createContacts() -> [ContactModel] {
    [
      createDemoContactModel1(),
      createDemoContactModel2(),
      createDemoContactModel3(),
      createDemoContactModel4(),
      createDemoContactModel5(),
      createDemoContactModel6(),
      createDemoContactModel7(),
      createDemoContactModel8(),
      createDemoContactModel9(),
      createDemoContactModel10(),
      createDemoContactModel11()
    ]
  }
  
  func createAppSettingsModel() -> AppSettingsModel {
    AppSettingsModel(
      appPassword: nil,
      fakeAppPassword: nil,
      accessType: .demo,
      pushNotificationToken: nil,
      isNotificationsEnabled: true,
      myStatus: .offline,
      toxStateAsString: nil,
      isPremiumEnabled: true,
      isTypingIndicatorEnabled: true,
      canSaveMedia: true,
      isChatHistoryStored: true,
      isVoiceChangerEnabled: true
    )
  }
  
  func createMessengesModels() -> [String: [MessengeModel]] {
    var dictionaries: [[String: [MessengeModel]]] = [
      createMessengesModel1(),
      createMessengesModel2(),
      createMessengesModel3(),
      createMessengesModel4(),
      createMessengesModel5(),
      createMessengesModel6(),
      createMessengesModel7(),
      createMessengesModel8(),
      createMessengesModel9(),
      createMessengesModel10(),
      createMessengesModel11()
    ]
    
    let combinedDict = dictionaries.reduce([:]) { (result, dict) in
        result.merging(dict) { (current, _) in current }
    }
    return combinedDict
  }
}
// swiftlint:enable all
