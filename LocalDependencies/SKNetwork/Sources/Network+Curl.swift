//
//  URLRequest+Curl.swift
//
//
//  Created by Vitalii Sosin on 30.04.2022.
//

import Foundation

extension URLRequest {
  
  /// Генерирует `Curl` запрос
  public var curlString: String {
    guard let url = url else { return "\n🤦🏼‍♂️ пустой url?!\n" }
    
    guard let method = httpMethod else { return "\n🌚 отсутствует httpMethod. How?\n" }
    
    var baseCommand = String(format: "curl -k -X %@", method)
    
    if let headers = allHTTPHeaderFields {
      for (key, value) in headers {
        let escapedValue = value.replacingOccurrences(of: "\"", with: "\\\"")
        let escapedKey = key.replacingOccurrences(of: "\"", with: "\\\"")
        let row = String(format: " \\\n -H \"%@: %@\"", escapedKey, escapedValue)
        baseCommand.append(row)
      }
    }
    
    if let data = httpBody, let body = String(data: data, encoding: .utf8) {
      let row = String.init(format: " \\\n -d '%@'", body.replacingOccurrences(of: "'", with: "\\'"))
      baseCommand.append(row)
    }
    
    return baseCommand.appendingFormat(" \\\n \"%@\" --dump-header -", url.absoluteString)
  }
}
