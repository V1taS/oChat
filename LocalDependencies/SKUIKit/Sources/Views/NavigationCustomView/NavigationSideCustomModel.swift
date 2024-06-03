//
//  NavigationSideCustomModel.swift
//
//
//  Created by Vitalii Sosin on 21.01.2024.
//

import SwiftUI

// MARK: - NavigationSideCustomModel

public enum NavigationSideCustomModel: Equatable {
  var image: Image {
    switch self {
    case .cancel, .none:
      return Image(systemName: "xmark")
    case .done:
      return Image(systemName: "checkmark")
    case .refresh:
      return Image(systemName: "arrow.circlepath")
    case .share:
      return Image(systemName: "square.and.arrow.up")
    case .delete:
      return Image(systemName: "trash")
    case .write:
      return Image(systemName: "square.and.pencil")
    case .custom:
      return Image(uiImage: UIImage())
    }
  }
  
  case cancel
  case done
  case refresh
  case share
  case delete
  case write
  case custom(_ text: String, image: Image? = nil)
  case none
}
