//
//  DataMappingService.swift
//  oChat
//
//  Created by Vitalii Sosin on 26.02.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SwiftUI
import SKAbstractions

// MARK: - DataMappingService

public final class DataMappingService: IDataMappingService {
  public init() {}
  
  public func encodeModel<T: Encodable>(
    _ model: T,
    completion: @escaping (Result<Data, Error>
    ) -> Void) {
    let encoder = JSONEncoder()
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        let encodedData = try encoder.encode(model)
        DispatchQueue.main.async {
          completion(.success(encodedData))
        }
      } catch {
        DispatchQueue.main.async {
          completion(.failure(error))
        }
      }
    }
  }
  
  public func decodeModel<T: Decodable>(
    _ type: T.Type,
    from data: Data,
    completion: @escaping (Result<T, Error>) -> Void
  ) {
    let decoder = JSONDecoder()
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        let decodedObject = try decoder.decode(type, from: data)
        DispatchQueue.main.async {
          completion(.success(decodedObject))
        }
        
      } catch {
        DispatchQueue.main.async {
          completion(.failure(error))
        }
      }
    }
  }
}
