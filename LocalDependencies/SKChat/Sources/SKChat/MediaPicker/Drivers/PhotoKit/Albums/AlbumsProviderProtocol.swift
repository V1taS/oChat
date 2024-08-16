//
//  Created by Sosin Vitalii on 02.06.2023.
//

import Foundation
import Combine

protocol AlbumsProviderProtocol {
  var albums: AnyPublisher<[AlbumModel], Never> { get }
  
  func reload()
}
