//
//  GeminiResponse.swift
//  lernig
//
//  Created by Furkan Gönel on 29.07.2025.
//


import Foundation


struct GeminiResponse: Codable {
    let candidates: [Candidate]
}


struct Candidate: Codable {
    let content: Content
}


struct Content: Codable {
    let parts: [Part]
}


struct Part: Codable {
    let text: String
}
