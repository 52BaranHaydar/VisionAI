//
//  VisionViewModel.swift
//  VisionAI
//
//  Created by Baran on 22.03.2026.
//

import Foundation
import UIKit
import Combine

class VisionViewModel: ObservableObject{
    
    @Published var selectedImage: UIImage?
    @Published var isLiveMode = false
    @Published var history: [HistoryItem] = []
    @Published var results: [ClassificationResult] = []
    
    let classificationService = ClassificationService.shared
    let cameraService = CameraService.shared
    
    
    var isProcessing: Bool{
        classificationService.isProcessing
    }
    
    var topResult: ClassificationResult?{
        classificationService.results.first
    }
    
    init(){
        setupLiveCamera()
    }
    
    // Fotoğrafları sınıflandır
    func classifyImage(_ image: UIImage) {
        selectedImage = image
        Task {
            await classificationService.classify(image: image)
            await MainActor.run {
                self.results = classificationService.results
                print("✅ ViewModel results: \(self.results.count)")
            }
        }
    }
    
    func setupLiveCamera(){
        cameraService.onFrameCaptured = { [weak self] image in
            guard let self = self, self.isLiveMode else { return }
            Task{
                await self.classificationService.classify(image: image)
            }
        }
    }
    
    func toggleLiveMode(){
        isLiveMode.toggle()
        if isLiveMode{
            cameraService.startSession()
        } else {
            cameraService.stopSession()
        }
    }
    
    // Geçmişi Temizle
    func clearHistory(){
        history.removeAll()
    }
    
}

struct HistoryItem: Identifiable{
    let id = UUID()
    let image: UIImage
    let label: String
    let confidence: Double
    let date = Date()
    
    var confidencePercentage: String {
        String(format: "%.1f%%", confidence * 100)
    }
}
