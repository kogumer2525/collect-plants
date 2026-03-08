@preconcurrency import AVFoundation
import SwiftUI
import Combine

class CameraService: NSObject, ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var isAuthorized = false
    @Published var currentPosition: AVCaptureDevice.Position = .back

    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private var photoContinuation: CheckedContinuation<UIImage, Error>?
    private let sessionQueue = DispatchQueue(label: "com.collectplants.camera.session", qos: .userInitiated)

    override init() {
        super.init()
        checkAuthorization()
    }

    func checkAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            DispatchQueue.main.async { self.isAuthorized = true }
            sessionQueue.async { self.setupSession() }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard let self else { return }
                DispatchQueue.main.async { self.isAuthorized = granted }
                if granted { self.sessionQueue.async { self.setupSession() } }
            }
        default:
            isAuthorized = false
        }
    }

    private func setupSession(position: AVCaptureDevice.Position = .back) {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
              let input = try? AVCaptureDeviceInput(device: device) else { return }

        session.beginConfiguration()
        for existing in session.inputs {
            session.removeInput(existing)
        }
        if session.canAddInput(input) { session.addInput(input) }
        if session.canAddOutput(output) { session.addOutput(output) }
        session.commitConfiguration()
    }

    func switchCamera() {
        sessionQueue.async {
            let newPosition: AVCaptureDevice.Position = self.currentPosition == .back ? .front : .back
            self.setupSession(position: newPosition)
            DispatchQueue.main.async { self.currentPosition = newPosition }
        }
    }

    func startSession() {
        sessionQueue.async {
            if self.session.inputs.isEmpty { self.setupSession(position: self.currentPosition) }
            if !self.session.isRunning { self.session.startRunning() }
        }
    }

    func stopSession() {
        sessionQueue.async {
            if self.session.isRunning { self.session.stopRunning() }
        }
    }

    func capturePhoto() async throws -> UIImage {
        return try await withCheckedThrowingContinuation { continuation in
            self.photoContinuation = continuation
            let settings = AVCapturePhotoSettings()
            self.output.capturePhoto(with: settings, delegate: self)
        }
    }
}

extension CameraService: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        Task { @MainActor in
            if let error = error {
                self.photoContinuation?.resume(throwing: error)
                self.photoContinuation = nil
                return
            }
            guard let data = photo.fileDataRepresentation(),
                  let image = UIImage(data: data) else {
                self.photoContinuation?.resume(throwing: CameraError.noImageData)
                self.photoContinuation = nil
                return
            }
            self.capturedImage = image
            self.photoContinuation?.resume(returning: image)
            self.photoContinuation = nil
        }
    }
}

enum CameraError: LocalizedError {
    case noImageData
    var errorDescription: String? { "画像データを取得できませんでした" }
}
