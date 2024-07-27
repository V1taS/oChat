//
//  PermissionService.swift
//  SafeKeeper
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
  
  @discardableResult
  public func requestNotification() async -> Bool {
    await withCheckedContinuation { continuation in
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
        continuation.resume(returning: granted)
        guard granted else { return }
        DispatchQueue.main.async {
          UIApplication.shared.registerForRemoteNotifications()
        }
      }
    }
  }
  
  @discardableResult
  public func isNotificationsEnabled() async -> Bool {
    await withCheckedContinuation { continuation in
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        continuation.resume(returning: settings.authorizationStatus == .authorized)
      }
    }
  }
  
  @discardableResult
  public func requestCamera() async -> Bool {
    await withCheckedContinuation { continuation in
      AVCaptureDevice.requestAccess(for: .video) { granted in
        continuation.resume(returning: granted)
      }
    }
  }
  
  @discardableResult
  public func requestGallery() async -> Bool {
    await withCheckedContinuation { continuation in
      if #available(iOS 14, *) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
          continuation.resume(returning: status == .authorized || status == .limited)
        }
      } else {
        PHPhotoLibrary.requestAuthorization { status in
          continuation.resume(returning: status == .authorized)
        }
      }
    }
  }
  
  @discardableResult
  public func requestFaceID() async -> Bool {
    await withCheckedContinuation { continuation in
      let context = LAContext()
      var error: NSError?
      
      guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
        continuation.resume(returning: false)
        return
      }
      
      context.evaluatePolicy(
        .deviceOwnerAuthenticationWithBiometrics,
        localizedReason: "Для доступа к приложению требуется аутентификация"
      ) { success, _ in
        continuation.resume(returning: success)
      }
    }
  }
}
