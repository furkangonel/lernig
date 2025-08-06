//
//  Lesson.swift
//  lernig
//
//  Created by Furkan Gönel on 29.07.2025.
//


import Foundation

struct Lesson: Identifiable, Codable {
    let id: String
    let userId: String
    let name: String
    let createdAt: Date
    
    init(id: String = UUID().uuidString, userId: String, name: String, createdAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.name = name
        self.createdAt = createdAt
    }
}
