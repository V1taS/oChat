//
//  PermissionService.swift
//  oChat
//
//  Created by Vitalii Sosin on 15.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import UIKit
import AppTrackingTransparency
import AdSupport
import Photos
import AVFoundation
import UserNotifications

public final class PermissionService {
  public static let shared = PermissionService()
  private var statusAction: ((_ isSuccess: Bool) -> Void)?
  private init() {}

  // MARK: - Открыть настройки приложения

  @MainActor
  public func openSettings() async {
    await withCheckedContinuation { continuation in
      guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
        continuation.resume()
        return
      }

      UIApplication.shared.open(settingsURL) { _ in
        continuation.resume()
      }
    }
  }

  // MARK: - Склеивание изображений (видимых ячеек / хедеров / футеров) на градиентном фоне

  /// Склеивает все **видимые** ячейки и видимые хедеры/футеры `UICollectionView` на экране в одно изображение.
  @MainActor
  public func captureMergedSnapshotsWithGradient() async -> Data? {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
      return nil
    }

    // Специальная структура для хранения снимков
    struct SnapshotItem {
      let section: Int
      let item: Int // Для header используем -1, для footer — Int.max
      let image: UIImage
    }

    var snapshotItems = [SnapshotItem]()
    let spacing: CGFloat = 4

    // 1. Ищем все UICollectionView во всех окнах активной сцены
    for window in windowScene.windows {
      for subview in window.subviews {
        guard let collectionView = findCollectionView(in: subview) else { continue }

        // --- 1.1. Видимые ячейки ---
        let sortedCells = collectionView.visibleCells.sorted { cell1, cell2 in
          guard
            let indexPath1 = collectionView.indexPath(for: cell1),
            let indexPath2 = collectionView.indexPath(for: cell2)
          else {
            return false
          }
          // Сортируем сначала по секции, потом по item
          if indexPath1.section == indexPath2.section {
            return indexPath1.item < indexPath2.item
          } else {
            return indexPath1.section < indexPath2.section
          }
        }

        for cell in sortedCells {
          if let indexPath = collectionView.indexPath(for: cell),
             let image = cell.contentView.snapshotImage() {
            snapshotItems.append(
              SnapshotItem(section: indexPath.section,
                           item: indexPath.item,
                           image: image)
            )
          }
        }

        // --- 1.2. Видимые Headers и Footers ---
        // Шаблон: для header используем item = -1, для footer — Int.max

        // Headers
        let headerIndexPaths = collectionView.indexPathsForVisibleSupplementaryElements(
          ofKind: UICollectionView.elementKindSectionHeader
        )
        for indexPath in headerIndexPaths {
          if let headerView = collectionView.supplementaryView(
            forElementKind: UICollectionView.elementKindSectionHeader,
            at: indexPath
          ), let image = headerView.snapshotImage() {
            snapshotItems.append(
              SnapshotItem(section: indexPath.section,
                           item: -1,
                           image: image)
            )
          }
        }

        // Footers
        let footerIndexPaths = collectionView.indexPathsForVisibleSupplementaryElements(
          ofKind: UICollectionView.elementKindSectionFooter
        )
        for indexPath in footerIndexPaths {
          if let footerView = collectionView.supplementaryView(
            forElementKind: UICollectionView.elementKindSectionFooter,
            at: indexPath
          ), let image = footerView.snapshotImage() {
            snapshotItems.append(
              SnapshotItem(section: indexPath.section,
                           item: Int.max,
                           image: image)
            )
          }
        }
      }
    }

    // 2. Если нет ни одной видимой ячейки/хедера/футера, возвращаем nil
    guard !snapshotItems.isEmpty else {
      return nil
    }

    // 3. Сортируем глобально все элементы (section, item)
    snapshotItems.sort { lhs, rhs in
      if lhs.section == rhs.section {
        return lhs.item < rhs.item
      } else {
        return lhs.section < rhs.section
      }
    }

    // Преобразуем к просто массиву изображений по порядку
    let images = snapshotItems.map { $0.image }

    // 4. Рассчитываем итоговые размеры
    let maxWidth = images.map { $0.size.width }.max() ?? 0
    let totalHeight = images.reduce(0) { $0 + $1.size.height } + spacing * CGFloat(images.count - 1)

    // Дополнительные отступы (по желанию)
    let horizontalPadding: CGFloat = 16
    let verticalPadding: CGFloat = 16

    let finalWidth = maxWidth + horizontalPadding * 2
    let finalHeight = totalHeight + verticalPadding * 2
    let finalSize = CGSize(width: finalWidth, height: finalHeight)

    // 5. Генерируем случайный градиент
    let (startColor, endColor) = randomGradientColors()

    // 6. Рисуем итоговое изображение
    let renderer = UIGraphicsImageRenderer(size: finalSize)
    let finalImage = renderer.image { context in
      let cgContext = context.cgContext

      // Отрисовываем градиент
      let colorSpace = CGColorSpaceCreateDeviceRGB()
      let colors = [startColor.cgColor, endColor.cgColor] as CFArray
      guard let gradient = CGGradient(colorsSpace: colorSpace,
                                      colors: colors,
                                      locations: [0, 1]) else {
        return
      }
      let startPoint = CGPoint(x: finalSize.width / 2, y: 0)
      let endPoint = CGPoint(x: finalSize.width / 2, y: finalSize.height)
      cgContext.drawLinearGradient(gradient,
                                   start: startPoint,
                                   end: endPoint,
                                   options: [])

      // Отрисовываем каждый скриншот с нужным отступом
      var currentY = verticalPadding
      for image in images {
        let x = (finalWidth - image.size.width) / 2
        image.draw(in: CGRect(x: x,
                              y: currentY,
                              width: image.size.width,
                              height: image.size.height))
        currentY += image.size.height + spacing
      }
    }

    // Сжимаем в JPEG (или PNG, если нужно)
    return finalImage.jpegData(compressionQuality: 0.7)
  }

  // MARK: - Сохранение изображения в галерею

  public func saveImageToGallery(_ imageData: Data?) async -> Bool {
    await withCheckedContinuation { continuation in
      guard
        let imageData,
        let image = UIImage(data: imageData)
      else {
        continuation.resume(returning: false)
        return
      }

      // Сохраняем изображение в альбом
      UIImageWriteToSavedPhotosAlbum(
        image,
        self,
        #selector(image(_:didFinishSavingWithError:contextInfo:)),
        nil
      )

      // Определяем результат сохранения в селекторе
      self.statusAction = { isSuccess in
        continuation.resume(returning: isSuccess)
      }
    }
  }

  @objc
  private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
    if error != nil {
      statusAction?(false)
    } else {
      statusAction?(true)
    }
  }

  // MARK: - Уведомления

  public func getNotification() async -> UNAuthorizationStatus {
    await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
  }

  public func requestNotification() async -> Bool {
    let center = UNUserNotificationCenter.current()
    let granted = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
    if granted == true {
      await MainActor.run {
        UIApplication.shared.registerForRemoteNotifications()
      }
    }
    return granted ?? false
  }

  // MARK: - IDFA

  @discardableResult
  public func requestIDFA() async -> ATTrackingManager.AuthorizationStatus {
    let currentStatus = ATTrackingManager.trackingAuthorizationStatus
    if currentStatus == .notDetermined {
      return await ATTrackingManager.requestTrackingAuthorization()
    }
    return currentStatus
  }

  public func getIDFA() -> String {
    ASIdentifierManager.shared().advertisingIdentifier.uuidString
  }

  // MARK: - Камера

  public func requestCamera() async -> Bool {
    await AVCaptureDevice.requestAccess(for: .video)
  }

  // MARK: - Фото

  @discardableResult
  public func requestPhotos() async -> Bool {
    if #available(iOS 14, *) {
      let resultStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
      return (resultStatus == .authorized || resultStatus == .limited)
    } else {
      let resultStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
      return (resultStatus == .authorized || resultStatus == .limited)
    }
  }
}

// MARK: - Поиск UICollectionView

private extension PermissionService {
  /// Рекурсивный поиск первого (или вложенного) `UICollectionView` в иерархии subviews
  func findCollectionView(in view: UIView) -> UICollectionView? {
    if let collectionView = view as? UICollectionView {
      return collectionView
    }
    for subview in view.subviews {
      if let collectionView = findCollectionView(in: subview) {
        return collectionView
      }
    }
    return nil
  }
}

// MARK: - UIView Snapshot

private extension UIView {
  /// Создание скриншота текущего `UIView` при помощи `UIGraphicsImageRenderer`.
  func snapshotImage() -> UIImage? {
    let format = UIGraphicsImageRendererFormat.default()
    format.scale = UIScreen.main.scale
    let renderer = UIGraphicsImageRenderer(bounds: bounds, format: format)
    return renderer.image { context in
      layer.render(in: context.cgContext)
    }
  }
}

// MARK: - Случайный градиент

private extension PermissionService {
  /// Генерирует два случайных `UIColor` для градиента.
  func randomGradientColors() -> (UIColor, UIColor) {
    let color1 = UIColor(
      hue: .random(in: 0...1),
      saturation: .random(in: 0.5...1),
      brightness: .random(in: 0.8...1),
      alpha: 1
    )
    let color2 = UIColor(
      hue: .random(in: 0...1),
      saturation: .random(in: 0.5...1),
      brightness: .random(in: 0.8...1),
      alpha: 1
    )
    return (color1, color2)
  }
}
