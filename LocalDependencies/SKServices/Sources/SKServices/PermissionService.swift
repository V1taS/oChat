//
//  PermissionService.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.01.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import Photos
import UserNotifications
import SwiftUI
import SKAbstractions
import LocalAuthentication

// MARK: - Permission Service

public final class PermissionService: IPermissionService {
  public init() {}
  
  public func requestNotification(completion: @escaping (_ granted: Bool) -> Void) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
      DispatchQueue.main.async {
        completion(granted)
        guard granted else { return }
        UIApplication.shared.registerForRemoteNotifications()
      }
    }
  }
  
  public func isNotificationsEnabled(completion: @escaping (_ enabled: Bool) -> Void) {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      DispatchQueue.main.async {
        completion(settings.authorizationStatus == .authorized)
      }
    }
  }
  
  public func requestCamera(completion: @escaping (_ granted: Bool) -> Void) {
    AVCaptureDevice.requestAccess(for: .video) { granted in
      DispatchQueue.main.async {
        completion(granted)
      }
    }
  }
  
  public func requestGallery(completion: @escaping (_ granted: Bool) -> Void) {
    if #available(iOS 14, *) {
      PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
        DispatchQueue.main.async {
          completion(status == .authorized || status == .limited)
        }
      }
    } else {
      PHPhotoLibrary.requestAuthorization { status in
        DispatchQueue.main.async {
          completion(status == .authorized)
        }
      }
    }
  }
  
  public func requestFaceID(completion: @escaping (_ granted: Bool) -> Void) {
    let context = LAContext()
    var error: NSError?
    
    guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
      DispatchQueue.main.async {
        completion(false)
      }
      return
    }
    
    context.evaluatePolicy(
      .deviceOwnerAuthenticationWithBiometrics,
      localizedReason: "Для доступа к приложению требуется аутентификация"
    ) { success, error in
      DispatchQueue.main.async {
        completion(success)
      }
    }
  }
}
