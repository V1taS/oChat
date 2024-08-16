//
//  Created by Sosin Vitalii on 02.06.2023.
//

import Foundation
import Photos

public struct Album: Identifiable {
  public let id: String
  public let title: String?
  public let preview: PHAsset?
}

struct AlbumModel {
  let preview: AssetMediaModel?
  let source: PHAssetCollection
}

extension AlbumModel: Identifiable {
  public var id: String {
    source.localIdentifier
  }
  
  public var title: String? {
    source.localizedTitle
  }
}

extension AlbumModel: Equatable {}

extension AlbumModel {
  func toAlbum() -> Album {
    Album(id: id, title: title, preview: preview?.asset)
  }
}
