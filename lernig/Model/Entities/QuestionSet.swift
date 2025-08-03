//
//  QuestionGroup.swift
//  lernig
//
//  Created by Furkan Gönel on 30.07.2025.
//

import Foundation

struct QuestionSet: Identifiable, Codable {
    let id: String
    let topicId: String
    let name: String
    let description: String?
    let createdAt: Date
    
    init(id: String = UUID().uuidString, topicId: String, name: String, description: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.topicId = topicId
        self.name = name
        self.description = description
        self.createdAt = createdAt
    }
}
