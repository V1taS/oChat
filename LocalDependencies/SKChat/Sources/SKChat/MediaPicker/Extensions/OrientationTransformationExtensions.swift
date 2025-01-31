//
//  OrientationTransformationExtensions.swift
//
//
//  Created by Sosin Vitalii on 02.06.2023.
//

import UIKit
import AVFoundation

extension UIImage.Orientation {
  
  init(_ deviceOrientation: UIDeviceOrientation) {
    switch deviceOrientation {
    case .landscapeLeft: self = .up
    case .landscapeRight: self = .down
    case .portraitUpsideDown: self = .left
    default: self = .right
    }
  }
  
  static var `default`: UIImage.Orientation { .right }
}

extension AVCaptureVideoOrientation {
  
  init(_ orientation: UIDeviceOrientation) {
    switch orientation {
    case .landscapeLeft: self = .landscapeRight
    case .landscapeRight: self = .landscapeLeft
    default: self = .portrait
    }
  }
  
}
