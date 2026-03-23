//
//  ContentView.swift
//  VisionAI
//
//  Created by Baran on 22.03.2026.
//
import SwiftUI
import PhotosUI

struct ContentView: View {
    @StateObject private var viewModel = VisionViewModel()
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showCamera = false
    @State private var showHistory = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Görüntü alanı
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray6))
                            .frame(height: 300)
                        
                        if let image = viewModel.selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 300)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 60))
                                    .foregroundStyle(.secondary)
                                Text("Fotoğraf seç veya çek")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        if viewModel.isProcessing {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.black.opacity(0.5))
                                    .frame(height: 300)
                                VStack(spacing: 12) {
                                    ProgressView()
                                        .tint(.white)
                                        .scaleEffect(1.5)
                                    Text("Analiz Ediliyor...")
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                    }
                    .frame(height: 300)
                    .padding(.horizontal)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    // Butonlar
                    HStack(spacing: 16) {
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            Label("Galeri", systemImage: "photo.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .onChange(of: selectedPhoto) { _, item in
                            Task {
                                if let data = try? await item?.loadTransferable(type: Data.self),
                                   let image = UIImage(data: data) {
                                    await MainActor.run {
                                        viewModel.classifyImage(image)
                                    }
                                }
                            }
                        }
                        
                        Button {
                            showCamera = true
                        } label: {
                            Label("Kamera", systemImage: "camera.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                    .padding(.horizontal)
                    
                    // Bilgi kartı
                    if let topResult = viewModel.results.first {
                        InfoCardView(
                            result: topResult,
                            wikiInfo: viewModel.wikiInfo,
                            isLoading: viewModel.isLoadingWiki
                        )
                        .padding(.horizontal)
                    }
                    
                    // Sonuçlar
                    if !viewModel.results.isEmpty {
                        ResultsView(results: viewModel.results)
                            .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            .navigationTitle("VisionAI 🤖")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showHistory = true
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundStyle(.blue)
                    }
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraView(viewModel: viewModel)
            }
            .sheet(isPresented: $showHistory) {
                HistoryView(viewModel: viewModel)
            }
        }
    }
}

struct ResultsView: View {
    let results: [ClassificationResult]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Analiz Sonuçları")
                .font(.headline)
            
            ForEach(results) { result in
                VStack(spacing: 6) {
                    HStack {
                        Text(result.cleanLabel)
                            .font(.subheadline)
                            .fontWeight(result.id == results.first?.id ? .bold : .regular)
                        Spacer()
                        Text(result.confidencePercentage)
                            .font(.subheadline)
                            .foregroundStyle(result.confidence > 0.7 ? .green : result.confidence > 0.4 ? .orange : .red)
                    }
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray5))
                                .frame(height: 8)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(result.confidence > 0.7 ? Color.green : result.confidence > 0.4 ? Color.orange : Color.red)
                                .frame(width: geo.size.width * result.confidence, height: 8)
                        }
                    }
                    .frame(height: 8)
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.06), radius: 6)
            }
        }
    }
}

#Preview {
    ContentView()
}
