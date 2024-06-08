//
//  ContactModel+ImageStatus.swift
//  SKUIKit
//
//  Created by Vitalii Sosin on 08.06.2024.
//

import UIKit
import SKStyle
import SKAbstractions

// MARK: - Status

extension ContactModel.Status {
  /// Изображения по статусам
  public var imageStatus: UIImage? {
    switch self {
    case .online:
      UIImage(
        named: SKStyleAsset.oChatOnline.name,
        in: SKStyleResources.bundle,
        with: nil
      )
    case .offline:
      UIImage(
        named: SKStyleAsset.oChatOffline.name,
        in: SKStyleResources.bundle,
        with: nil
      )
    case .inProgress, .requested:
      UIImage(
        named: SKStyleAsset.oChatInProgress.name,
        in: SKStyleResources.bundle,
        with: nil
      )
    }
  }
}
