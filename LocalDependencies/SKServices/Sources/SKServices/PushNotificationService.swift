//
//  PushNotificationService.swift
//  SKServices
//
//  Created by Vitalii Sosin on 25.06.2024.
//

import Foundation
import CommonCrypto
import CryptoKit
import SKAbstractions

public struct PushNotificationService: IPushNotificationService {
  
  // MARK: - Initialization
  
  public init() {}
  
  // MARK: - Methods
  
  public func sendPushNotification(title: String, body: String, customData: [String: Any], deviceToken: String) {
#if DEBUG
    let urlString = "\(Secrets.ushNotificationTestURL)\(deviceToken)"
#else
    let urlString = "\(Secrets.pushNotificationProdURL)\(deviceToken)"
#endif
    
    var request = URLRequest(url: URL(string: urlString)!)
    request.httpMethod = "POST"
    request.setValue("bearer \(generateJWT())", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("com.sosinvitalii.oChat", forHTTPHeaderField: "apns-topic")
    request.setValue("alert", forHTTPHeaderField: "apns-push-type")
    request.setValue("10", forHTTPHeaderField: "apns-priority")
    request.setValue("0", forHTTPHeaderField: "apns-expiration")
    
    var payload: [String: Any] = [
      "aps": [
        "alert": [
          "title": title,
          "body": body
        ],
        "sound": "default"
      ]
    ]
    
    for (key, value) in customData {
      payload[key] = value
    }
    
    request.httpBody = try? JSONSerialization.data(withJSONObject: payload, options: [])
    
    DispatchQueue.global().async {
      let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
          print("❌ Error sending push notification: \(error)")
          return
        }
        
        if let response = response as? HTTPURLResponse, response.statusCode == 200 {
          print("✅ Push notification sent successfully!")
        } else {
          print("❌ Error sending push notification: \(response.debugDescription)")
        }
      }
      task.resume()
    }
  }
  
  private func generateJWT() -> String {
    let header = [
      "alg": "ES256",
      "kid": Secrets.pushNotificationKeyID
    ]
    
    let payload: [String : Any] = [
      "iss": Secrets.pushNotificationTeamID,
      "iat": Int(Date().timeIntervalSince1970)
    ]
    
    guard let headerData = try? JSONSerialization.data(withJSONObject: header, options: []),
          let payloadData = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
      return ""
    }
    
    let headerBase64 = headerData.base64EncodedString()
      .replacingOccurrences(of: "=", with: "")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "+", with: "-")
    let payloadBase64 = payloadData.base64EncodedString()
      .replacingOccurrences(of: "=", with: "")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "+", with: "-")
    
    let headerPayload = "\(headerBase64).\(payloadBase64)"
    let signature = sign(headerPayload: headerPayload)
    return "\(headerPayload).\(signature)"
  }
}

// MARK: - Private

private extension PushNotificationService {
  func sign(headerPayload: String) -> String {
    guard let key = try? P256.Signing.PrivateKey(pemRepresentation: Secrets.pushNotificationAuthKey) else {
      return ""
    }
    
    let signature = try? key.signature(for: Data(headerPayload.utf8))
    let signatureBase64 = signature?.rawRepresentation.base64EncodedString()
      .replacingOccurrences(of: "=", with: "")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "+", with: "-")
    return signatureBase64 ?? ""
  }
}
