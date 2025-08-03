//
//  Question.swift
//  lernig
//
//  Created by Furkan Gönel on 29.07.2025.
//


import Foundation

struct Question: Identifiable, Codable {
    let id: String
    let topicId: String
    let questionSetId: String?
    let questionText: String
    let answerText: String
    let type: QuestionType
    let testData: TestQuestionData? // Only for test type questions
    let createdAt: Date
    
    init(id: String = UUID().uuidString, topicId: String, questionSetId: String? = nil, questionText: String, answerText: String, type: QuestionType, testData: TestQuestionData? = nil, createdAt: Date = Date()) {
        self.id = id
        self.topicId = topicId
        self.questionSetId = questionSetId
        self.questionText = questionText
        self.answerText = answerText
        self.type = type
        self.testData = testData
        self.createdAt = createdAt
    }
}
