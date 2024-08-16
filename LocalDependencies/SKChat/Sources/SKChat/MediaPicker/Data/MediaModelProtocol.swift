//
//  SwiftUIView.swift
//
//
//  Created by Sosin Vitalii on 02.06.2023.
//

import SwiftUI

protocol MediaModelProtocol {
  var mediaType: MediaType? { get }
  var duration: CGFloat? { get }
  
  func getURL() async -> URL?
  func getThumbnailURL() async -> URL?
  
  func getData() async throws -> Data?
  func getThumbnailData() async -> Data?
}
