//
//  CameraService.swift
//  VisionAI
//
//  Created by Baran on 22.03.2026.
//

import Foundation
import AVFoundation
import UIKit
import Combine

class CameraService: NSObject, ObservableObject {
    
    static let shared = CameraService()
    
    @Published var capturedImage: UIImage?
    @Published var isSessionRunning = false
    
    private let session = AVCaptureSession()
    private let output = AVCaptureVideoDataOutput()
    private var lastCaptureTime = Date()
    
    var onFrameCaptured: ((UIImage) -> Void)?
    
    override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        session.beginConfiguration()
        session.sessionPreset = .high
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera.queue"))
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        session.commitConfiguration()
    }
    
    func startSession() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.session.startRunning()
            DispatchQueue.main.async {
                self?.isSessionRunning = true
            }
        }
    }
    
    func stopSession() {
        session.stopRunning()
        isSessionRunning = false
    }
    
    func getSession() -> AVCaptureSession {
        return session
    }
}

extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        // Her 1 saniyede bir kare al
        let now = Date()
        guard now.timeIntervalSince(lastCaptureTime) >= 1.0 else { return }
        lastCaptureTime = now
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
        let image = UIImage(cgImage: cgImage)
        
        DispatchQueue.main.async { [weak self] in
            self?.capturedImage = image
            self?.onFrameCaptured?(image)
        }
    }
}
