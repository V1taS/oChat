//
//  ToxOptions.swift
//
//
//  Created by Vitalii Sosin on 09.06.2024.
//

import Foundation
import ToxCoreCpp

// Добавляем свойства для хранения C строк
private var torProxyHostData: Data?

/// Структура для хранения настроек Tox.
public struct ToxOptions {
  /// Включение поддержки IPv6. Если значение true, то IPv6 будет использоваться.
  public var ipv6Enabled: Bool
  
  /// Включение поддержки UDP. Если значение true, то UDP будет использоваться.
  public var udpEnabled: Bool
  
  /// Начальный порт для Tox. Если значение равно 0, будет выбран случайный порт.
  public var startPort: UInt16
  
  /// Конечный порт для Tox. Если значение равно 0, будет выбран случайный порт.
  public var endPort: UInt16
  
  /// Порт для TCP соединений. Если значение равно 0, TCP будет отключен.
  public var tcpPort: UInt16
  
  /// Включение поддержки пробивки NAT (hole punching). Если значение true, NAT пробивка будет использоваться.
  public var holePunchingEnabled: Bool
  
  /// Включение поддержки локального обнаружения. Если значение true, локальное обнаружение будет использоваться.
  public var localDiscoveryEnabled: Bool
  
  /// Включение поддержки DHT объявлений. Если значение true, DHT объявления будут использоваться.
  public var dhtAnnouncementsEnabled: Bool
  
  /// Включение экспериментальной поддержки сохранения групп. Если значение true, сохранение групп будет использоваться.
  public var experimentalGroupsPersistence: Bool
  
  /// Ффлаг для использования прокси TOR
  public var useTorProxy: Bool
  
  /// Конструктор с настройками по умолчанию.
  public init() {
    self.ipv6Enabled = false
    self.udpEnabled = true
    self.startPort = 0
    self.endPort = 0
    self.tcpPort = 0
    self.holePunchingEnabled = true
    self.localDiscoveryEnabled = true
    self.dhtAnnouncementsEnabled = true
    self.experimentalGroupsPersistence = false
    self.useTorProxy = false
  }
}

extension ToxOptions {
  /// Преобразование настроек в формат, поддерживаемый Tox.
  /// - Parameter options: Опции для настройки Tox.
  /// - Returns: Возвращает объект `Tox_Options`, заполненный на основе переданных опций.
  public static func convertToToxOptions(from options: ToxOptions) -> Tox_Options {
    var toxOptions = Tox_Options()
    
    tox_options_default(&toxOptions)
    toxOptions.ipv6_enabled = options.ipv6Enabled
    toxOptions.udp_enabled = options.udpEnabled
    toxOptions.start_port = options.startPort
    toxOptions.end_port = options.endPort
    toxOptions.tcp_port = options.tcpPort
    toxOptions.hole_punching_enabled = options.holePunchingEnabled
    toxOptions.local_discovery_enabled = options.localDiscoveryEnabled
    toxOptions.dht_announcements_enabled = options.dhtAnnouncementsEnabled
    toxOptions.experimental_groups_persistence = options.experimentalGroupsPersistence
    
    // Настройка для использования TOR
    if options.useTorProxy {
      toxOptions.proxy_type = TOX_PROXY_TYPE_SOCKS5
      
      // Преобразуем строку в C строку и сохраняем в Data
      guard let proxyHostCString = "127.0.0.1".cString(using: .utf8) else {
        print("Ошибка: не удалось преобразовать строку '127.0.0.1' в C строку.")
        return toxOptions
      }
      torProxyHostData = Data(cString: proxyHostCString)
      
      // Устанавливаем указатель на C строку
      torProxyHostData?.withUnsafeBytes { bytes in
        toxOptions.proxy_host = bytes.baseAddress?.assumingMemoryBound(to: CChar.self)
      }
      toxOptions.proxy_port = 9050
    }
    return toxOptions
  }
}
