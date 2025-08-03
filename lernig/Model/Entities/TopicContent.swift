//
//  TopicContent.swift
//  lernig
//
//  Created by Furkan Gönel on 29.07.2025.
//


import Foundation


struct TopicContent: Identifiable, Codable {
    let id: String
    let topicId: String
    let text: String
    let createdAt: Date
    
    init(id: String = UUID().uuidString, topicId: String, text: String, createdAt: Date = Date()) {
        self.id = id
        self.topicId = topicId
        self.text = text
        self.createdAt = createdAt
    }
}
