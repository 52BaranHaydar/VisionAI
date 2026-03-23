//
//  ClassificationService.swift
//  VisionAI
//
//  Created by Baran on 22.03.2026.
//

import Foundation
import CoreML
import Vision
import UIKit
import Combine

class ClassificationService: ObservableObject{
    
    static let shared = ClassificationService()
    
    @Published var results:[ClassificationResult] = []
    @Published var isProcessing = false
    @Published var error: String = ""
    
    private var model: VNCoreMLModel?
    
    init(){
        setupModel()
    }
    
    private func setupModel(){
        do{
            let config = MLModelConfiguration()
            config.computeUnits = .all
            let mlModel = try MobileNetV2Int8LUT(configuration: config)
            model = try VNCoreMLModel(for: mlModel.model)
            self.error = ""
        } catch{
            self.error = "Model yüklemedi: \(error.localizedDescription)"
        }
    }
    
    func classify(image: UIImage) async {
        guard let model = model,
              let ciImage = CIImage(image: image) else {
            print("❌ Model veya CIImage oluşturulamadı")
            return
        }
        
        await MainActor.run {
            isProcessing = true
            results = []
        }
        
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            if let error = error {
                print("❌ Vision hatası: \(error)")
                return
            }
            guard let observations = request.results as? [VNClassificationObservation] else {
                print("❌ Observations alınamadı")
                return
            }
            
            print("✅ \(observations.count) sonuç bulundu")
            print("✅ İlk sonuç: \(observations.first?.identifier ?? "yok")")
            
            let top5 = observations.prefix(5).map {
                ClassificationResult(
                    label: $0.identifier,
                    confidence: Double($0.confidence)
                )
            }
            
            DispatchQueue.main.async {
                self?.results = top5
                self?.isProcessing = false
                print("✅ UI güncellendi: \(top5.count) sonuç")
            }
        }
        
        request.imageCropAndScaleOption = .centerCrop
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        do {
            try handler.perform([request])
        } catch {
            print("❌ Handler hatası: \(error)")
            await MainActor.run {
                self.error = error.localizedDescription
                self.isProcessing = false
            }
        }
    }
    
}

struct ClassificationResult: Identifiable{
    let id = UUID()
    let label : String
    let confidence: Double
    
    var confidencePercentage: String{
        String(format: "%.1f%%", confidence * 100)
    }
    
    var cleanLabel: String{
        label.split(separator: ",").first?.trimmingCharacters(in: .whitespaces) ?? label
    }
}
