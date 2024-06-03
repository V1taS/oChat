//
//  UIService.swift
//  SKServices
//
//  Created by Vitalii Sosin on 21.03.2024.
//

import SwiftUI
import SKAbstractions
import SKStyle
import CoreImage.CIFilterBuiltins
import SKFoundation

// MARK: - UIService

public final class UIService: IUIService {

  // MARK: - Private properties
  
  private lazy var imageSaver = ImageToGallerySaver()
  
  // MARK: - Init
  
  public init() {}
  
  // MARK: - Public func
  
  public func saveColorScheme(_ interfaceStyle: UIUserInterfaceStyle?) {
    if let interfaceStyle {
      let isDarkMode = interfaceStyle == .dark
      UserDefaults.standard.set(isDarkMode, forKey: Constants.colorSchemeKey)
    } else {
      UserDefaults.standard.removeObject(forKey: Constants.colorSchemeKey)
    }
  }
  
  public func getColorScheme() -> UIUserInterfaceStyle? {
    let isDarkMode = UserDefaults.standard.object(forKey: Constants.colorSchemeKey) as? Bool
    if let isDarkMode {
      return isDarkMode ? .dark : .light
    } else {
      return nil
    }
  }
  
  public func generateQRCode(
    from string: String,
    iconIntoQR: UIImage?,
    completion: ((UIImage?) -> Void)?
  ) {
    generateQRCode(
      from: string,
      backgroundColor: .clear,
      foregroundColor: SKStyleAsset.constantNavy.swiftUIColor,
      iconIntoQR: iconIntoQR,
      iconSize: CGSize(width: 100, height: 100),
      completion: completion
    )
  }
  
  public func generateQRCode(
    from string: String,
    backgroundColor: Color,
    foregroundColor: Color,
    iconIntoQR: UIImage?,
    iconSize: CGSize,
    completion: ((UIImage?) -> Void)?
  ) {
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      let context = CIContext()
      let filter = CIFilter.qrCodeGenerator()
      filter.message = Data(string.utf8)
      filter.correctionLevel = "H"
      
      if let qrCodeCIImage = filter.outputImage {
        let transformedImage = qrCodeCIImage.transformed(
          by: CGAffineTransform(scaleX: 10, y: 10)
        )
        let colorParameters = [
          "inputColor0": CIColor(color: foregroundColor.uiColor),
          "inputColor1": CIColor(color: backgroundColor.uiColor)
        ]
        let colorFilter = CIFilter(name: "CIFalseColor", parameters: colorParameters)
        colorFilter?.setValue(transformedImage, forKey: "inputImage")
        
        if let coloredImage = colorFilter?.outputImage,
           let qrCodeCGImage = context.createCGImage(coloredImage, from: coloredImage.extent) {
          let qrCodeImage = UIImage(cgImage: qrCodeCGImage)
          let icon = self?.insertIcon(iconIntoQR, in: qrCodeImage, iconSize: iconSize)
          DispatchQueue.main.async {
            completion?(icon)
            return
          }
        }
      }
    }
  }
  
  public func saveImageToGallery(_ imageData: Data?, completion: ((Bool) -> Void)?) {
    imageSaver.saveImageToGallery(imageData, completion: completion)
  }
  
  public func getImage(for url: URL?, completion: @escaping (UIImage?) -> Void) {
    ImageCacheService.shared.getImage(for: url, completion: completion)
  }
}

// MARK: - Private

private extension UIService {
  func insertIcon(
    _ iconIntoQR: UIImage?,
    in qrCodeImage: UIImage,
    iconSize: CGSize,
    iconBackgroundColor: Color = SKStyleAsset.ghost.swiftUIColor
  ) -> UIImage? {
    var icon = UIImage()
    var iconBackgroundColor: UIColor = iconBackgroundColor.uiColor
    
    if let iconImage = iconIntoQR {
      icon = iconImage
    } else {
      iconBackgroundColor = .clear
    }
    
    let size = qrCodeImage.size
    let scale = UIScreen.main.scale
    UIGraphicsBeginImageContextWithOptions(size, false, scale)
    
    qrCodeImage.draw(in: CGRect(origin: CGPoint.zero, size: size))
    let iconRect = CGRect(x: (size.width - iconSize.width) / 2.0,
                          y: (size.height - iconSize.height) / 2.0,
                          width: iconSize.width,
                          height: iconSize.height)
    
    let path = UIBezierPath(ovalIn: iconRect)
    iconBackgroundColor.setFill()
    path.fill()
    icon.draw(in: iconRect)
    let resultImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return resultImage
  }
}

// MARK: - Constants

private enum Constants {
  static let colorSchemeKey = "darkModePreference"
}
