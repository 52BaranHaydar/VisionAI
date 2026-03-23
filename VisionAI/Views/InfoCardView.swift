//
//  InfoCardView.swift
//  VisionAI
//
//  Created by Baran on 23.03.2026.
//

import SwiftUI

struct InfoCardView: View {
    let result: ClassificationResult
    let wikiInfo: WikipediaResult?
    let isLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Başlık
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.cleanLabel.capitalized)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(result.confidencePercentage + " güven")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                ZStack {
                    Circle()
                        .stroke(result.confidence > 0.7 ? Color.green : result.confidence > 0.4 ? Color.orange : Color.red, lineWidth: 3)
                        .frame(width: 50, height: 50)
                    Text(result.confidencePercentage)
                        .font(.caption2)
                        .fontWeight(.bold)
                }
            }
            
            Divider()
            
            // Wikipedia bilgisi
            if isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Bilgi yükleniyor...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else if let wiki = wikiInfo {
                VStack(alignment: .leading, spacing: 12) {
                    
                    // Wikipedia açıklaması
                    Text(wiki.shortExtract)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .lineSpacing(4)
                    
                    // Wikipedia linki
                    if let urlString = wiki.content_urls?.desktop?.page,
                       let url = URL(string: urlString) {
                        Link(destination: url) {
                            HStack {
                                Image(systemName: "globe")
                                Text("Wikipedia'da Oku")
                                    .font(.subheadline)
                                Image(systemName: "arrow.up.right")
                                    .font(.caption)
                            }
                            .foregroundStyle(.blue)
                        }
                    }
                }
            } else {
                Text("Bu nesne hakkında bilgi bulunamadı.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 10)
    }
}

#Preview {
    InfoCardView(
        result: ClassificationResult(label: "cliff, drop", confidence: 0.85),
        wikiInfo: nil,
        isLoading: true
    )
    .padding()
}
