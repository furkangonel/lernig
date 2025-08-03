//
//  Topic.swift
//  lernig
//
//  Created by Furkan Gönel on 29.07.2025.
//


import Foundation


struct Topic: Identifiable, Codable {
    let id: String
    let lessonId: String
    let name: String
    let createdAt: Date
    
    init(id: String = UUID().uuidString, lessonId: String, name: String, createdAt: Date = Date()) {
        self.id = id
        self.lessonId = lessonId
        self.name = name
        self.createdAt = createdAt
    }
}
