//
//  SKBarButtonItem.swift
//  SKUIKit
//
//  Created by Vitalii Sosin on 18.04.2024.
//

import UIKit
import SKStyle

final public class SKBarButtonItem: UIBarButtonItem {
  
  // MARK: - Private properties
  
  private var barButtonAction: (() -> Void)?
  private let impactFeedback = UIImpactFeedbackGenerator(style: .soft)

  // MARK: - Init
  
  public init(_ buttonType: SKBarButtonItem.ButtonType,
              isEnabled: Bool = true) {
    super.init()
    self.image = buttonType.image
    self.style = .plain
    setTitleTextAttributes([.font: UIFont.fancy.text.regularMedium], for: .normal)
    self.title = buttonType.title
    self.target = self
    self.action = #selector(barButtonSelector)
    self.barButtonAction = buttonType.action
    self.tintColor = SKStyleAsset.azure.color
    self.isEnabled = isEnabled
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - Private

private extension SKBarButtonItem {
  @objc private func barButtonSelector() {
    barButtonAction?()
    impactFeedback.impactOccurred()
  }
}

// MARK: - ButtonType

extension SKBarButtonItem {
  public enum ButtonType {
    var action: (() -> Void)? {
      switch self {
      case let .close(action):
        return action
      case let .done(action):
        return action
      case let .refresh(action):
        return action
      case let .share(action):
        return action
      case let .delete(action):
        return action
      case let .write(action):
        return action
      case let .text(_, action):
        return action
      }
    }
    
    var title: String? {
      switch self {
      case let .text(text, _):
        return text
      default:
        return nil
      }
    }
    
    var image: UIImage? {
      switch self {
      case .close:
        return UIImage(systemName: "xmark")
      case .done:
        return UIImage(systemName: "checkmark")
      case .refresh:
        return UIImage(systemName: "arrow.circlepath")
      case .share:
        return UIImage(systemName: "square.and.arrow.up")
      case .delete:
        return UIImage(systemName: "trash")
      case .write:
        return UIImage(systemName: "square.and.pencil")
      case .text:
        return nil
      }
    }
    
    case close(action: (() -> Void)?)
    case done(action: (() -> Void)?)
    case refresh(action: (() -> Void)?)
    case share(action: (() -> Void)?)
    case delete(action: (() -> Void)?)
    case write(action: (() -> Void)?)
    case text(_ text: String, action: (() -> Void)?)
  }
}
