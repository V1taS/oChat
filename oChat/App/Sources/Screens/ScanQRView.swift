//
//  ScanQRView.swift
//  oChat
//
//  Created by Vitalii Sosin on 11.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import SwiftUI
import AVFoundation

// MARK: - Palette
private enum Palette {
  static let sheetBG   = Color(.systemGroupedBackground)
  static let accent    = Color(red: 0/255, green: 183/255, blue: 241/255)
}

// MARK: - Экран
@MainActor
struct ScanQRView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var isScanning = true

  /// Вернёт строку с найденным кодом и закроет экран
  var onComplete: (String) -> Void = { _ in }

  var body: some View {
    NavigationStack {
      qrScanner
        .navigationTitle("Сканировать QR")
        .navigationBarTitleDisplayMode(.inline)
        .background(Palette.sheetBG.ignoresSafeArea())
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            Button {
              dismiss()
            } label: {
              Image(systemName: "xmark")
                .font(.headline)
            }
          }
        }
    }
  }
}

// MARK: - Сканер / Заглушка симулятора
private extension ScanQRView {
  @ViewBuilder
  var qrScanner: some View {
#if targetEnvironment(simulator)
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
      CameraPreview(isRunning: $isScanning) { code in
        onComplete(code)
      }
      .ignoresSafeArea()

      // Полупрозрачная маска
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

      // Рамка сканируемой области
      RoundedRectangle(cornerRadius: 24, style: .continuous)
        .strokeBorder(Color.white.opacity(0.8), lineWidth: 2)
        .frame(width: 280, height: 280)
    }
#endif
  }
}

// MARK: - Представление камеры (как в NewMessageView)
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

  // MARK: - Coordinator
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

    // MARK: - Delegate
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
      guard
        let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
        let string = object.stringValue
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

// MARK: - Preview
#Preview {
  ScanQRView()
}
