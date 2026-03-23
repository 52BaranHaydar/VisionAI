//
//  HistoryView.swift
//  VisionAI
//
//  Created by Baran on 23.03.2026.
//
import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: VisionViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.history.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)
                        Text("Henüz analiz yapılmadı")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    List {
                        ForEach(viewModel.history) { item in
                            HStack(spacing: 12) {
                                Image(uiImage: item.image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.label)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Text(item.confidencePercentage)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(item.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Geçmiş")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Temizle") {
                        viewModel.clearHistory()
                    }
                    .foregroundStyle(.red)
                    .disabled(viewModel.history.isEmpty)
                }
            }
        }
    }
}

#Preview {
    HistoryView(viewModel: VisionViewModel())
}
