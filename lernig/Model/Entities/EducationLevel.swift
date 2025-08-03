//
//  EducationLevel.swift
//  lernig
//
//  Created by Furkan Gönel on 29.07.2025.
//


import Foundation


enum EducationLevel: String, CaseIterable, Codable {
    case elementary = "elementary"
    case middle = "middle"
    case highschool = "highschool"
    case university = "university"
    
    var displayName: String {
        switch self {
        case .elementary: return "İlkokul"
        case .middle: return "Ortaokul"
        case .highschool: return "Lise"
        case .university: return "Üniversite"
        }
    }
}
