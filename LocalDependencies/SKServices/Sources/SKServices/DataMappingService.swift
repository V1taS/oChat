//
//  DataMappingService.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 26.02.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SwiftUI
import SKAbstractions

// MARK: - DataMappingService

public final class DataMappingService: IDataMappingService {
  public init() {}
  
  public func encodeModel<T: Encodable>(_ model: T) async throws -> Data? {
    let encoder = JSONEncoder()
    let encodedData = try? encoder.encode(model)
    return encodedData
  }
  
  public func decodeModel<T: Decodable>(
    _ type: T.Type,
    from data: Data
  ) async throws -> T? {
    let decoder = JSONDecoder()
    let decodedObject = try? decoder.decode(type, from: data)
    return decodedObject
  }
}
