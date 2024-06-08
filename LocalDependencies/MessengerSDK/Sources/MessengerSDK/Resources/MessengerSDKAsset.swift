//
//  MessengerSDKAsset.swift
//  MessengerSDK
//
//  Created by Vitalii Sosin on 06.06.2024.
//

import UIKit

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
public enum MessengerSDKAsset {
  public static let emptyStateLottie = MessengerSDKData(name: "empty_state_lottie")
  public static let circleNetworkLoaderLottie = MessengerSDKData(name: "circle_network_loader")
  public static let keyExchangeAnimation = MessengerSDKData(name: "key_exchange_animation")
  public static let p2pChating = MessengerSDKData(name: "p2p_chating")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

public struct MessengerSDKData {
  public fileprivate(set) var name: String
  
#if os(iOS) || os(tvOS) || os(macOS)
  @available(iOS 9.0, macOS 10.11, *)
  public var data: NSDataAsset {
    guard let data = NSDataAsset(asset: self) else {
      fatalError("Unable to load data asset named \(name).")
    }
    return data
  }
#endif
}

#if os(iOS) || os(tvOS) || os(macOS)
@available(iOS 9.0, macOS 10.11, *)
public extension NSDataAsset {
  convenience init?(asset: MessengerSDKData) {
    let bundle = MessengerSDKResources.bundle
#if os(iOS) || os(tvOS)
    self.init(name: asset.name, bundle: bundle)
#elseif os(macOS)
    self.init(name: NSDataAsset.Name(asset.name), bundle: bundle)
#endif
  }
}
#endif
