//
//  QuestionType.swift
//  lernig
//
//  Created by Furkan Gönel on 31.07.2025.
//


import Foundation

enum QuestionType: String, CaseIterable, Codable {
    case classic
    case test
    
    var displayName: String {
        switch self {
        case .classic: return "Klasik Soru-Cevap"
        case .test: return "Çoktan Seçmeli"
        }
    }
}
