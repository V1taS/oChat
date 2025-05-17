//
//  NewMessageView.swift
//  oChat
//
//  Created by Vitalii Sosin on 11.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import SwiftUI
import AVFoundation

// MARK: - Palette
private enum Palette {
  static let sheetBG = Color(.systemGroupedBackground)
  static let separator = Color.gray.opacity(0.22)
  static let accent = Color(red: 0/255, green: 183/255, blue: 241/255) // цвет индикатора
}

// MARK: - Вкладки
private enum InputMode: String, CaseIterable {
  case manual = "Введите Account ID"
  case scanQR = "Сканировать QR-код"
}

// MARK: - Экран
struct NewMessageView: View {
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject var toxManager: ToxManager

  @State private var selection: InputMode = .manual
  @State private var accountID: String = ""
  @State private var isScanning = false

  var onComplete: (String) -> Void = { _ in }

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        topTabs
          .padding(.top, 4)

        switch selection {
        case .manual:
          manualEntryView
            .transition(.opacity)
        case .scanQR:
          qrScannerView
            .transition(.opacity)
        }

        Spacer()
      }
      .background(Palette.sheetBG.ignoresSafeArea())
      .navigationTitle("Новое сообщение")
      .navigationBarTitleDisplayMode(.large)
      .onChange(of: selection) { value, _ in
        // запускаем/останавливаем сканер при переключении вкладки
        isScanning = (value == .scanQR)
      }
    }
  }
}

// MARK: - Верхние вкладки
private extension NewMessageView {
  var topTabs: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        ForEach(InputMode.allCases, id: \.self) { mode in
          Button {
            withAnimation(.spring(duration: 0.35)) { selection = mode }
          } label: {
            Text(mode.rawValue)
              .font(.subheadline.weight(.semibold))
              .padding(.vertical, 10)
              .frame(maxWidth: .infinity)
          }
          .buttonStyle(.plain)
        }
      }

      // Индикатор выбранной вкладки
      GeometryReader { geo in
        Capsule()
          .fill(Palette.accent)
          .frame(width: geo.size.width / 2, height: 3)
          .offset(x: selection == .manual ? 0 : geo.size.width / 2,
                  y: 0)
          .animation(.spring(duration: 0.35), value: selection)
      }
      .frame(height: 3)
    }
  }
}

// MARK: - Ручной ввод
private extension NewMessageView {
  var manualEntryView: some View {
    VStack(spacing: 22) {
      TextField("Введите Account ID или ONS", text: $accountID, axis: .vertical)
        .textInputAutocapitalization(.never)
        .disableAutocorrection(true)
        .textFieldStyle(.roundedBorder)   // нативная закруглённая рамка
        .padding(.horizontal)
        .padding(.top)

      Text("Начните новую беседу, введя ID аккаунта вашего друга, ONS или отсканировав их QR-код.")
        .font(.footnote)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 28)

      Button {
        guard !accountID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        onComplete(accountID)
        dismiss()
      } label: {
        Text("Продолжить")
          .font(.headline)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 14)
          .background(Palette.accent)
          .foregroundStyle(.white)
          .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
      }
      .padding(.horizontal, 28)
      .padding(.top, 6)
      
      Spacer(minLength: 0)
    }
  }
}

// MARK: - Сканер QR-кода / Заглушка для симулятора
private extension NewMessageView {
  @ViewBuilder
  var qrScannerView: some View {
#if targetEnvironment(simulator)
    // Заглушка, когда приложение запущено в симуляторе
    VStack(spacing: 16) {
      Image(systemName: "qrcode.viewfinder")
        .resizable()
        .scaledToFit()
        .frame(width: 120, height: 120)
        .foregroundStyle(.secondary)

      Text("Сканирование QR-кодов недоступно\nв симуляторе")
        .multilineTextAlignment(.center)
        .font(.footnote)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
#else
    ZStack {
      CameraPreview(isRunning: $isScanning) { foundCode in
        onComplete(foundCode)
        dismiss()
      }
      .ignoresSafeArea()

      // Полупрозрачная маска + рамка
      Color.black.opacity(0.4)
        .mask {
          Rectangle()
            .overlay(
              RoundedRectangle(cornerRadius: 24, style: .continuous)
                .frame(width: 280, height: 280)
                .blendMode(.destinationOut)
            )
        }
        .compositingGroup()

      RoundedRectangle(cornerRadius: 24, style: .continuous)
        .strokeBorder(Color.white.opacity(0.8), lineWidth: 2)
        .frame(width: 280, height: 280)
    }
#endif
  }
}

// MARK: - Представление камеры
private struct CameraPreview: UIViewRepresentable {
  @Binding var isRunning: Bool
  var onFoundCode: (String) -> Void

  func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

  func makeUIView(context: Context) -> PreviewView {
    let view = PreviewView()
    context.coordinator.configureSession(for: view)
    return view
  }

  func updateUIView(_ uiView: PreviewView, context: Context) {
    isRunning ? context.coordinator.start() : context.coordinator.stop()
  }

  // MARK: Coordinator
  final class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    private let session  = AVCaptureSession()
    private var parent: CameraPreview?

    init(parent: CameraPreview) { self.parent = parent }

    func configureSession(for preview: PreviewView) {
      preview.videoPreviewLayer.session = session

      guard
        let device  = AVCaptureDevice.default(for: .video),
        let input   = try? AVCaptureDeviceInput(device: device),
        session.canAddInput(input)
      else { return }

      session.addInput(input)

      let output = AVCaptureMetadataOutput()
      if session.canAddOutput(output) {
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = [.qr]
      }
    }

    func start() { if !session.isRunning { session.startRunning() } }
    func stop()  { if  session.isRunning { session.stopRunning()  } }

    // MARK: Delegate
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
      guard
        let object  = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
        let string  = object.stringValue
      else { return }

      parent?.onFoundCode(string)
      stop()
    }
  }
}

// MARK: - Preview helper UIView
private final class PreviewView: UIView {
  override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
  var videoPreviewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
}

// MARK: – Preview

#Preview {
  NavigationStack {
    NewMessageView()
      .environmentObject(ToxManager.preview)
  }
}
