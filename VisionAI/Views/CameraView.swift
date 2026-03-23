//
//  CameraView.swift
//  VisionAI
//
//  Created by Baran on 23.03.2026.
//
import SwiftUI
import AVFoundation

struct CameraView: View {
    @ObservedObject var viewModel: VisionViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                CameraPreviewView(session: viewModel.cameraService.getSession())
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    
                    if let result = viewModel.topResult {
                        VStack(spacing: 8) {
                            Text(result.cleanLabel)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            Text(result.confidencePercentage)
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("Canlı Tanıma")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") {
                        viewModel.cameraService.stopSession()
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.toggleLiveMode()
                    } label: {
                        Text(viewModel.isLiveMode ? "Durdur" : "Başlat")
                            .foregroundStyle(.white)
                    }
                }
            }
            .onAppear {
                viewModel.cameraService.startSession()
                viewModel.isLiveMode = true
            }
            .onDisappear {
                viewModel.cameraService.stopSession()
                viewModel.isLiveMode = false
            }
        }
    }
}

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = UIScreen.main.bounds
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

#Preview {
    CameraView(viewModel: VisionViewModel())
}
