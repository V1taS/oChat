//
//  ToxServiceOptions.swift
//  ToxSwift
//
//  Created by Vitalii Sosin on 07.05.2025.
//  Полная версия с поддержкой пунктов 1–8 (локальное обнаружение и DHT‑анонсы).
//

import Foundation
import CTox
import CSodium

// MARK: – Конфигурация сервиса Tox

/// Опции для настройки поведения и подключения Tox.
public struct ToxServiceOptions: Sendable {

  // ───────── Сеть ─────────
  /// Включить IPv6 (по умолчанию `false`).
  public var isIPv6Enabled: Bool
  /// Включить UDP (по умолчанию `true`).
  public var isUDPEnabled: Bool
  /// Включить локальное обнаружение устройств в LAN (по умолчанию `true`).
  public var isLocalDiscoveryEnabled: Bool
  /// Публиковать анонсы в DHT (по умолчанию `true`).
  public var isDHTAnnouncementsEnabled: Bool

  // ───────── Прокси ─────────
  public var proxyType: ProxyKind
  public var proxyHost: String
  public var proxyPort: UInt16
  /// С‑enum, который потребует toxcore.
  public var cProxyType: TOX_PROXY_TYPE { proxyType.cValue }

  // ───────── Порты ─────────
  public var startPort: UInt16
  public var endPort: UInt16
  public var tcpPort: UInt16

  // ───────── Backup / Restore ─────────
  public var savedataType: SavedataKind
  public var savedata: Data?
  /// С‑enum для toxcore.
  public var cSavedataType: Tox_Savedata_Type { savedataType.cValue }

  // MARK: – Инициализаторы

  /// Удобный Swift‑инициализатор.
  public init(
    isIPv6Enabled: Bool = false,
    isUDPEnabled: Bool = false,
    isLocalDiscoveryEnabled: Bool = false,
    isDHTAnnouncementsEnabled: Bool = false,
    proxy: ProxyKind = .none,
    proxyHost: String = "",
    proxyPort: UInt16 = 0,
    startPort: UInt16 = 33445,
    endPort: UInt16 = 33445,
    tcpPort: UInt16 = 0,
    savedataType: SavedataKind = .none,
    savedata: Data? = nil
  ) {
    self.isIPv6Enabled             = isIPv6Enabled
    self.isUDPEnabled              = isUDPEnabled
    self.isLocalDiscoveryEnabled   = isLocalDiscoveryEnabled
    self.isDHTAnnouncementsEnabled = isDHTAnnouncementsEnabled
    self.proxyType                 = proxy
    self.proxyHost                 = proxyHost
    self.proxyPort                 = proxyPort
    self.startPort                 = startPort
    self.endPort                   = endPort
    self.tcpPort                   = tcpPort
    self.savedataType              = savedataType
    self.savedata                  = savedata
  }

  /// Инициализатор с «сырыми» C‑enum‑ами (когда приходят из C‑кода).
  public init(
    isIPv6Enabled: Bool,
    isUDPEnabled: Bool,
    isLocalDiscoveryEnabled: Bool = false,
    isDHTAnnouncementsEnabled: Bool = false,
    proxy: TOX_PROXY_TYPE = TOX_PROXY_TYPE_NONE,
    proxyHost: String = "",
    proxyPort: UInt16 = 0,
    startPort: UInt16 = 0,
    endPort: UInt16 = 0,
    tcpPort: UInt16 = 0,
    savedataType: Tox_Savedata_Type = TOX_SAVEDATA_TYPE_NONE,
    savedata: Data? = nil
  ) {
    self.isIPv6Enabled             = isIPv6Enabled
    self.isUDPEnabled              = isUDPEnabled
    self.isLocalDiscoveryEnabled   = isLocalDiscoveryEnabled
    self.isDHTAnnouncementsEnabled = isDHTAnnouncementsEnabled
    self.proxyType                 = ProxyKind.from(proxy)
    self.proxyHost                 = proxyHost
    self.proxyPort                 = proxyPort
    self.startPort                 = startPort
    self.endPort                   = endPort
    self.tcpPort                   = tcpPort
    self.savedataType              = SavedataKind.from(savedataType)
    self.savedata                  = savedata
  }
}

// MARK: – Прокси‑режимы

/// Swift‑friendly wrapper над `TOX_PROXY_TYPE`.
public enum ProxyKind: Sendable {
  case none
  case http
  case socks5

  var cValue: TOX_PROXY_TYPE {
    switch self {
    case .none:   return TOX_PROXY_TYPE_NONE
    case .http:   return TOX_PROXY_TYPE_HTTP
    case .socks5: return TOX_PROXY_TYPE_SOCKS5
    }
  }

  static func from(_ c: TOX_PROXY_TYPE) -> Self {
    switch c {
    case TOX_PROXY_TYPE_HTTP:   return .http
    case TOX_PROXY_TYPE_SOCKS5: return .socks5
    default:                    return .none
    }
  }
}

// MARK: – Savedata‑режимы

/// Swift‑friendly wrapper над `Tox_Savedata_Type`.
public enum SavedataKind: Sendable {
  /// Нет данных (новый профиль).
  case none
  /// Blob, возвращённый `tox_get_savedata`.
  case toxSave
  /// Только секретный ключ длиной `TOX_SECRET_KEY_SIZE`.
  case secretKey

  // ↔︎ C‑enum
  var cValue: Tox_Savedata_Type {
    switch self {
    case .none:      return TOX_SAVEDATA_TYPE_NONE
    case .toxSave:   return TOX_SAVEDATA_TYPE_TOX_SAVE
    case .secretKey: return TOX_SAVEDATA_TYPE_SECRET_KEY
    }
  }

  static func from(_ c: Tox_Savedata_Type) -> Self {
    switch c {
    case TOX_SAVEDATA_TYPE_TOX_SAVE:   return .toxSave
    case TOX_SAVEDATA_TYPE_SECRET_KEY: return .secretKey
    default:                           return .none
    }
  }
}
