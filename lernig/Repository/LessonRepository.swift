//
//  LessonRepository.swift
//  lernig
//
//  Created by Furkan Gönel on 30.07.2025.
//

import Foundation
import FirebaseFirestore

protocol LessonRepository {
    // Lessons
    func fetchLessons(for userId: String) async throws -> [Lesson]
    func addLesson(_ lesson: Lesson) async throws
    func deleteLesson(_ lessonId: String) async throws
    
    // Topics
    func fetchTopics(for lessonId: String) async throws -> [Topic]
    func addTopic(_ topic: Topic) async throws
    func deleteTopic(_ topicId: String) async throws
    
    // Topic Contents
    func fetchContents(for topicId: String) async throws -> [TopicContent]
    func addContent(_ content: TopicContent) async throws
    func deleteContent(_ contentId: String) async throws
    
    // Question Sets
    func fetchQuestionSets(for topicId: String) async throws -> [QuestionSet]
    func addQuestionSet(_ questionSet: QuestionSet) async throws
    func deleteQuestionSet(_ questionSetId: String) async throws
    
    // Questions
    func fetchQuestions(for topicId: String) async throws -> [Question]
    func fetchQuestions(for questionSetId: String, in topicId: String) async throws -> [Question]
    func addQuestion(_ question: Question) async throws
    func deleteQuestion(_ questionId: String) async throws
    
    // AI
    func generateContent(lesson: String, topic: String, prompt: String, educationLevel: EducationLevel) async throws -> String
    func generateQuestions(lesson: String, topic: Topic, prompt: String, count: Int, educationLevel: EducationLevel, questionTypes: QuestionType) async throws -> [(question: String, answer: String)]
}

class FirestoreLessonRepository: LessonRepository {
    
    private let db = Firestore.firestore()
    
    // MARK: - Lessons
    func fetchLessons(for userId: String) async throws -> [Lesson] {
        let snapshot = try await db.collection("lessons")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Lesson.self)
        }
    }
    
    func addLesson(_ lesson: Lesson) async throws {
        try await db.collection("lessons").document(lesson.id).setData([
            "id": lesson.id,
            "userId": lesson.userId,
            "name": lesson.name,
            "createdAt": Timestamp(date: lesson.createdAt)
        ])
    }
    
    func deleteLesson(_ lessonId: String) async throws {
        try await db.collection("lessons").document(lessonId).delete()
    }
    
    // MARK: - Topics
    func fetchTopics(for lessonId: String) async throws -> [Topic] {
        let snapshot = try await db.collection("topics")
            .whereField("lessonId", isEqualTo: lessonId)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Topic.self)
        }
    }
    
    func addTopic(_ topic: Topic) async throws {
        try await db.collection("topics").document(topic.id).setData([
            "id": topic.id,
            "lessonId": topic.lessonId,
            "name": topic.name,
            "createdAt": Timestamp(date: topic.createdAt)
        ])
    }
    
    func deleteTopic(_ topicId: String) async throws {
        try await db.collection("topics").document(topicId).delete()
    }
    
    // MARK: - TopicContents
    func fetchContents(for topicId: String) async throws -> [TopicContent] {
        let snapshot = try await db.collection("contents")
            .whereField("topicId", isEqualTo: topicId)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: TopicContent.self)
        }
    }
    
    func addContent(_ content: TopicContent) async throws {
        try await db.collection("contents").document(content.id).setData([
            "id": content.id,
            "topicId": content.topicId,
            "text": content.text,
            "createdAt": Timestamp(date: content.createdAt)
        ])
    }
    
    func deleteContent(_ contentId: String) async throws {
        try await db.collection("contents").document(contentId).delete()
    }
    
    // MARK: - Questions
    func fetchQuestions(for topicId: String) async throws -> [Question] {
        let snapshot = try await db.collection("questions")
            .whereField("topicId", isEqualTo: topicId)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            
            let id = data["id"] as? String ?? doc.documentID
            let topicId = data["topicId"] as? String ?? ""
            let questionSetId = data["questionSetId"] as? String
            let questionText = data["questionText"] as? String ?? ""
            let answerText = data["answerText"] as? String ?? ""
            let typeString = data["type"] as? String ?? "classic"
            let type = QuestionType(rawValue: typeString) ?? .classic
            let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
            
            // Parse test data if it exists
            var testData: TestQuestionData? = nil
            if let testDataDict = data["testData"] as? [String: Any],
               let options = testDataDict["options"] as? [String],
               let correctOptionIndex = testDataDict["correctOptionIndex"] as? Int {
                testData = TestQuestionData(options: options, correctOptionIndex: correctOptionIndex)
            }
            
            return Question(
                id: id,
                topicId: topicId,
                questionSetId: questionSetId?.isEmpty == true ? nil : questionSetId,
                questionText: questionText,
                answerText: answerText,
                type: type,
                testData: testData,
                createdAt: createdAt
            )
        }
    }
    
    func fetchQuestions(for questionSetId: String, in topicId: String) async throws -> [Question] {
        let snapshot = try await db.collection("questions")
            .whereField("topicId", isEqualTo: topicId)
            .whereField("questionSetId", isEqualTo: questionSetId)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            
            let id = data["id"] as? String ?? doc.documentID
            let topicId = data["topicId"] as? String ?? ""
            let questionSetId = data["questionSetId"] as? String
            let questionText = data["questionText"] as? String ?? ""
            let answerText = data["answerText"] as? String ?? ""
            let typeString = data["type"] as? String ?? "classic"
            let type = QuestionType(rawValue: typeString) ?? .classic
            let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
            
            // Parse test data if it exists
            var testData: TestQuestionData? = nil
            if let testDataDict = data["testData"] as? [String: Any],
               let options = testDataDict["options"] as? [String],
               let correctOptionIndex = testDataDict["correctOptionIndex"] as? Int {
                testData = TestQuestionData(options: options, correctOptionIndex: correctOptionIndex)
            }
            
            return Question(
                id: id,
                topicId: topicId,
                questionSetId: questionSetId?.isEmpty == true ? nil : questionSetId,
                questionText: questionText,
                answerText: answerText,
                type: type,
                testData: testData,
                createdAt: createdAt
            )
        }
    }
    
    func addQuestion(_ question: Question) async throws {
        var questionData: [String: Any] = [
            "id": question.id,
            "topicId": question.topicId,
            "questionSetId": question.questionSetId ?? "",
            "questionText": question.questionText,
            "answerText": question.answerText,
            "type": question.type.rawValue,
            "createdAt": Timestamp(date: question.createdAt)
        ]
        
        // Add test data if it exists
        if let testData = question.testData {
            questionData["testData"] = [
                "options": testData.options,
                "correctOptionIndex": testData.correctOptionIndex
            ]
        }
        
        try await db.collection("questions").document(question.id).setData(questionData)
    }
    
    func deleteQuestion(_ questionId: String) async throws {
        try await db.collection("questions").document(questionId).delete()
    }
    
    // MARK: - Question Sets
    func fetchQuestionSets(for topicId: String) async throws -> [QuestionSet] {
        let snapshot = try await db.collection("questionSets")
            .whereField("topicId", isEqualTo: topicId)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: QuestionSet.self)
        }
    }
    
    func addQuestionSet(_ questionSet: QuestionSet) async throws {
        try await db.collection("questionSets").document(questionSet.id).setData([
            "id": questionSet.id,
            "topicId": questionSet.topicId,
            "name": questionSet.name,
            "description": questionSet.description ?? "",
            "createdAt": Timestamp(date: questionSet.createdAt)
        ])
    }
    
    func deleteQuestionSet(_ questionSetId: String) async throws {
        // First delete all questions in this set
        let questionsSnapshot = try await db.collection("questions")
            .whereField("questionSetId", isEqualTo: questionSetId)
            .getDocuments()
        
        for document in questionsSnapshot.documents {
            try await document.reference.delete()
        }
        
        // Then delete the question set
        try await db.collection("questionSets").document(questionSetId).delete()
    }
    
    // MARK: - AI Functions
    func generateContent(lesson: String, topic: String, prompt: String, educationLevel: EducationLevel) async throws -> String {
        // Direkt gerçek API çağrısı, hata durumunda üst katmana fırlatır
        return try await GeminiService.shared.generateLearningContent(
            lesson: lesson,
            topic: topic,
            userPrompt: prompt,
            educationLevel: educationLevel
        )
    }
    
    func generateQuestions(lesson: String, topic: Topic, prompt: String, count: Int, educationLevel: EducationLevel, questionTypes: QuestionType) async throws -> [(question: String, answer: String)] {
        let results = try await GeminiService.shared.generateQuestions(
            lesson: lesson,
            topic: topic,
            userPrompt: prompt,
            count: count,
            educationLevel: educationLevel,
            questionTypes: [questionTypes]
        )
        
        // Sadece soru ve cevabı dön
        return results.map { ($0.question, $0.answer) }
    }
    
    private func parseQuestionsFromResponse(_ response: String, count: Int) -> [(question: String, answer: String)] {
        // Bu fonksiyon artık kullanılmıyor ve mock kısımlar yok
        return []
    }
}
