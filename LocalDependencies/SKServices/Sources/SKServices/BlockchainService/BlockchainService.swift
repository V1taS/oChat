//
//  BlockchainService.swift
//  SKServices
//
//  Created by Vitalii Sosin on 10.05.2024.
//

import Foundation
import SKAbstractions

public final class BlockchainService: IBlockchainService {
  public let walletsManager: IWalletsManager
  public let tokenService: ITokenService
  
  public init() {
    self.walletsManager = WalletsManager()
    self.tokenService = TokenService()
  }
}
