//
//  ToxService+AV.swift
//  ToxSwift
//
//  Created by Vitalii Sosin on 07.05.2025.
//  Расширение для поддержки P2P‑аудио и видео‑звонков через ToxAV (CTox).
//

import Foundation
import CTox
import CSodium

// MARK: - Расширение ToxService

extension ToxService {

  // MARK: Внутренний контекст

  /// Контейнер, хранящий состояние AV‑подсистемы для конкретного `Tox`‑инстанса.
  final class AVContext {
    /// Указатель на `ToxAV` (opaque).
    var avPtr: OpaquePointer?
    /// Фоновая задача, выполняющая `toxav_iterate`.
    var loopTask: Task<Void, Never>?
    /// Асинхронный поток публичных событий.
    let stream: AsyncStream<CallEvent>
    /// Continuation для публикации событий.
    let continuation: AsyncStream<CallEvent>.Continuation

    init() {
      (stream, continuation) = AsyncStream<CallEvent>.makeStream()
    }
  }

  /// Сопоставление адреса `Tox`‑инстанса → `AVContext`.
  static var contexts: [UnsafeMutableRawPointer: AVContext] = [:]

  /// Возвращает AV‑контекст текущего сервиса, создавая при необходимости.
  var avContext: AVContext {
    let key = UnsafeMutableRawPointer(toxPointer)
    if let ctx = Self.contexts[key] { return ctx }
    let ctx = AVContext()
    Self.contexts[key] = ctx
    return ctx
  }

  // MARK: Публичный AsyncStream

  /// Асинхронный поток AV‑событий.
  ///
  /// При первом обращении инициализирует ToxAV и запускает event‑loop.
  public var callEvents: AsyncStream<CallEvent> {
    get async {
      _ = try? await setupAV()
      return avContext.stream
    }
  }

  // MARK: Инициализация AV‑сессии

  /// Создаёт (или возвращает уже созданный) экземпляр `ToxAV`,
  /// регистрирует все колбэки и запускает внутренний цикл `toxav_iterate`.
  ///
  /// - Throws: `ToxError.generic`, если `toxav_new` вернул ошибку.
  @discardableResult
  private func setupAV() async throws -> OpaquePointer {
    let ctx = avContext
    if let av = ctx.avPtr { return av }

    var errNew: Toxav_Err_New = TOXAV_ERR_NEW_OK
    guard let av = toxav_new(toxPointer, &errNew), errNew == TOXAV_ERR_NEW_OK else {
      throw ToxError.generic("toxav_new() failed: \(errNew)")
    }
    ctx.avPtr = av

    // Регистрируем C‑колбэки
    let ud = Unmanaged.passUnretained(self).toOpaque()
    toxav_callback_call(av, callCallback, ud)
    toxav_callback_call_state(av, callStateCallback, ud)
    toxav_callback_audio_receive_frame(av, audioReceiveCallback, ud)
    toxav_callback_video_receive_frame(av, videoReceiveCallback, ud)

    // Запускаем бесконечный цикл iterate в отдельной задаче
    ctx.loopTask = Task.detached(priority: .background) { [weak self] in
      await self?._avLoop()
    }

    return av
  }

  // MARK: Публичные методы управления вызовами

  /// Инициирует исходящий звонок.
  ///
  /// - Parameters:
  ///   - friendID: ID друга.
  ///   - audioBitRate: Битрейт аудио (бит/с).
  ///   - videoBitRate: Битрейт видео (kбит/с, задаётся в ToxAV целых).
  /// - Throws: Ошибка `Toxav_Err_Call`, обёрнутая в `ToxError.generic`.
  public func startCall(friendID: UInt32,
                        audioBitRate: UInt32 = 64_000,
                        videoBitRate: UInt32 = 200) async throws {
    let av = try await setupAV()
    var err: Toxav_Err_Call = TOXAV_ERR_CALL_OK
    guard toxav_call(av, friendID, audioBitRate, videoBitRate, &err),
          err == TOXAV_ERR_CALL_OK else {
      throw ToxError.generic("toxav_call() failed: \(err)")
    }
  }

  /// Принимает входящий звонок.
  ///
  /// - Parameters:
  ///   - friendID: ID друга‑звонящего.
  ///   - audioBitRate: Желаемый битрейт аудио.
  ///   - videoBitRate: Желаемый битрейт видео.
  /// - Throws: Ошибка `Toxav_Err_Answer`, обёрнутая в `ToxError.generic`.
  public func answerCall(friendID: UInt32,
                         audioBitRate: UInt32 = 64_000,
                         videoBitRate: UInt32 = 200) async throws {
    let av = try await setupAV()
    var err: Toxav_Err_Answer = TOXAV_ERR_ANSWER_OK
    guard toxav_answer(av, friendID, audioBitRate, videoBitRate, &err),
          err == TOXAV_ERR_ANSWER_OK else {
      throw ToxError.generic("toxav_answer() failed: \(err)")
    }
  }

  /// Управляет активным звонком (пауза/возобновление аудио/видео и т.д.).
  ///
  /// - Parameters:
  ///   - friendID: ID собеседника.
  ///   - control: Тип команды (`CallControl*`).
  /// - Throws: Ошибка `Toxav_Err_Call_Control`, обёрнутая в `ToxError.generic`.
  public func controlCall(friendID: UInt32,
                          control: CallControl) async throws {
    let av = try await setupAV()
    var err: Toxav_Err_Call_Control = TOXAV_ERR_CALL_CONTROL_OK
    guard toxav_call_control(av, friendID, control.cValue, &err),
          err == TOXAV_ERR_CALL_CONTROL_OK else {
      throw ToxError.generic("toxav_call_control() failed: \(err)")
    }
  }

  // MARK: Отправка фреймов

  /// Отправляет аудио‑фрейм собеседнику.
  ///
  /// - Parameters:
  ///   - friendID: ID собеседника.
  ///   - pcm: PCM‑буфер (little‑endian, 16‑bit).
  ///   - sampleCount: Кол‑во сэмплов на канал.
  ///   - channels: Число каналов.
  ///   - sampleRate: Частота дискретизации.
  /// - Throws: Ошибка `Toxav_Err_Send_Frame`, обёрнутая в `ToxError.generic`.
  public func sendAudioFrame(friendID: UInt32,
                             pcm: Data,
                             sampleCount: UInt32,
                             channels: UInt8,
                             sampleRate: UInt32) async throws {
    let av = try await setupAV()
    var err: Toxav_Err_Send_Frame = TOXAV_ERR_SEND_FRAME_OK

    try pcm.withUnsafeBytes { rawBuf in
      guard let ptr = rawBuf.baseAddress?.assumingMemoryBound(to: Int16.self) else {
        throw ToxError.generic("Invalid PCM buffer")
      }
      guard toxav_audio_send_frame(av, friendID, ptr,
                                   Int(sampleCount), channels, sampleRate, &err),
            err == TOXAV_ERR_SEND_FRAME_OK else {
        throw ToxError.generic("toxav_audio_send_frame() failed: \(err)")
      }
    }
  }

  /// Отправляет видео‑фрейм (формат YUV 420 planar).
  ///
  /// - Parameters:
  ///   - friendID: ID собеседника.
  ///   - width/height: Размер кадра.
  ///   - y/u/v: Плоскости яркости и цветности.
  /// - Throws: Ошибка `Toxav_Err_Send_Frame`, обёрнутая в `ToxError.generic`.
  public func sendVideoFrame(friendID: UInt32,
                             width: UInt16, height: UInt16,
                             y: Data, u: Data, v: Data) async throws {
    let av = try await setupAV()
    var err: Toxav_Err_Send_Frame = TOXAV_ERR_SEND_FRAME_OK

    try y.withUnsafeBytes { yBuf in
      try u.withUnsafeBytes { uBuf in
        try v.withUnsafeBytes { vBuf in
          guard let yPtr = yBuf.baseAddress?.assumingMemoryBound(to: UInt8.self),
                let uPtr = uBuf.baseAddress?.assumingMemoryBound(to: UInt8.self),
                let vPtr = vBuf.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
            throw ToxError.generic("Invalid YUV buffers")
          }
          guard toxav_video_send_frame(av, friendID, width, height,
                                       yPtr, uPtr, vPtr, &err),
                err == TOXAV_ERR_SEND_FRAME_OK else {
            throw ToxError.generic("toxav_video_send_frame() failed: \(err)")
          }
        }
      }
    }
  }

  // MARK: Внутренний цикл ToxAV

  /// Бесконечный цикл `toxav_iterate`, выполняется в фоновом `Task`.
  private func _avLoop() async {
    guard let av = avContext.avPtr else { return }
    while !Task.isCancelled {
      toxav_iterate(av)
      let ms = toxav_iteration_interval(av)
      try? await Task.sleep(nanoseconds: UInt64(ms) * 1_000_000)
    }
  }

  // MARK: Публикация события

  /// Потокобезопасно публикует событие в `callEvents`.
  @inline(__always)
  func _publish(_ event: CallEvent) {
    avContext.continuation.yield(event)
  }
}

// MARK: - C‑колбэки (@convention(c))
// Ниже располагаются низкоуровневые C‑функции обратного вызова,
// оборачивающие данные в `CallEvent` и передающие их в Swift‑поток.

// Тип‑алиас для читаемости
private typealias ToxAVPtr = OpaquePointer

/// Колбэк «входящий звонок / изменение состояния».
private let callCallback: @convention(c) (
  ToxAVPtr?, UInt32, Bool, Bool, UnsafeMutableRawPointer?
) -> Void = { _, friend, audioEn, videoEn, userData in
  guard let userData else { return }
  let svc = Unmanaged<ToxService>.fromOpaque(userData).takeUnretainedValue()
  Task { @Sendable [weak svc] in
    await svc?._publish(.call(friendID: friend,
                              audioEnabled: audioEn,
                              videoEnabled: videoEn))
  }
}

/// Колбэк изменения детализированного состояния звонка.
private let callStateCallback: @convention(c) (
  ToxAVPtr?, UInt32, UInt32, UnsafeMutableRawPointer?
) -> Void = { _, friend, stateRaw, userData in
  guard let userData else { return }

  let audio = (stateRaw & TOXAV_FRIEND_CALL_STATE_SENDING_A.rawValue) != 0
  let video = (stateRaw & TOXAV_FRIEND_CALL_STATE_SENDING_V.rawValue) != 0

  let svc = Unmanaged<ToxService>.fromOpaque(userData).takeUnretainedValue()
  Task { @Sendable [weak svc] in
    await svc?._publish(.call(friendID: friend,
                              audioEnabled: audio,
                              videoEnabled: video))
  }
}

/// Колбэк получения аудио‑фрейма.
private let audioReceiveCallback: @convention(c) (
  ToxAVPtr?, UInt32, UnsafePointer<Int16>?, Int, UInt8, UInt32, UnsafeMutableRawPointer?
) -> Void = { _, friend, pcmPtr, samples, channels, rate, userData in
  guard let pcmPtr, let userData else { return }

  let byteCount = samples * Int(channels) * MemoryLayout<Int16>.size
  let data = Data(bytes: pcmPtr, count: byteCount)

  let svc = Unmanaged<ToxService>.fromOpaque(userData).takeUnretainedValue()
  Task { @Sendable [weak svc] in
    await svc?._publish(.audioFrame(friendID: friend,
                                    sampleCount: UInt32(samples),
                                    channels: channels,
                                    sampleRate: rate,
                                    data: data))
  }
}

/// Колбэк получения видео‑фрейма.
private let videoReceiveCallback: @convention(c) (
  ToxAVPtr?, UInt32, UInt16, UInt16,
  UnsafePointer<UInt8>?, UnsafePointer<UInt8>?, UnsafePointer<UInt8>?,
  Int32, Int32, Int32, UnsafeMutableRawPointer?
) -> Void = { _, friend, width, height,
  yPtr, uPtr, vPtr,
  yStride, uStride, vStride,
  userData in
  guard let yPtr, let uPtr, let vPtr, let userData else { return }

  let ySize = Int(max(Int(width),  abs(Int(yStride)))) * Int(height)
  let uSize = Int(max(Int(width)/2, abs(Int(uStride)))) * Int(height) / 2
  let vSize = Int(max(Int(width)/2, abs(Int(vStride)))) * Int(height) / 2

  let yData = Data(bytes: yPtr, count: ySize)
  let uData = Data(bytes: uPtr, count: uSize)
  let vData = Data(bytes: vPtr, count: vSize)

  let svc = Unmanaged<ToxService>.fromOpaque(userData).takeUnretainedValue()
  Task { @Sendable [weak svc] in
    await svc?._publish(.videoFrame(friendID: friend,
                                    width: width, height: height,
                                    y: yData, u: uData, v: vData,
                                    yStride: yStride,
                                    uStride: uStride,
                                    vStride: vStride))
  }
}
