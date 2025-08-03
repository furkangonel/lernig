//
//  User.swift
//  lernig
//
//  Created by Furkan Gönel on 29.07.2025.
//


import Foundation



struct User: Identifiable, Codable {
    let id: String
    let name: String
    let username: String
    let email: String
    let educationLevel: EducationLevel
    let createdAt: Date
    
    init(id: String = UUID().uuidString, name: String, username: String, email: String, educationLevel: EducationLevel, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.username = username
        self.email = email
        self.educationLevel = educationLevel
        self.createdAt = createdAt
    }
}
