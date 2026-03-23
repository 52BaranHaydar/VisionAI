//
//  WikipediaService.swift
//  VisionAI
//
//  Created by Baran on 23.03.2026.
//

import Foundation

class WikipediaService {
    
    static let shared = WikipediaService()
    
    func fetchInfo(for query: String) async -> WikipediaResult? {
        let cleanQuery = query.split(separator: ",").first?
            .trimmingCharacters(in: .whitespaces) ?? query
        
        let encoded = cleanQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://en.wikipedia.org/api/rest_v1/page/summary/\(encoded)"
        
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let result = try JSONDecoder().decode(WikipediaResult.self, from: data)
            return result
        } catch {
            print("Wikipedia hatası: \(error)")
            return nil
        }
    }
}

struct WikipediaResult: Codable {
    let title: String
    let extract: String?
    let thumbnail: WikiThumbnail?
    let content_urls: WikiContentURLs?
    
    struct WikiThumbnail: Codable {
        let source: String?
    }
    
    struct WikiContentURLs: Codable {
        let desktop: WikiDesktopURL?
        
        struct WikiDesktopURL: Codable {
            let page: String?
        }
    }
    
    var shortExtract: String {
        guard let extract = extract else { return "Bilgi bulunamadı" }
        let sentences = extract.components(separatedBy: ". ")
        return sentences.prefix(3).joined(separator: ". ") + "."
    }
}
