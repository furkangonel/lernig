//
//  LessonViewModel.swift
//  lernig
//
//  Created by Furkan Gönel on 30.07.2025.
//

import Foundation
import Combine

@MainActor
class LessonViewModel: ObservableObject {
    
    // MARK: - Published properties
    @Published var lessons: [Lesson] = []
    @Published var topics: [Topic] = []
    @Published var contents: [TopicContent] = []
    @Published var questions: [Question] = []
    @Published var questionSets: [QuestionSet] = []
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // Form input'larını buradan da yönetebilirsin (opsiyonel):
    @Published var newLessonName: String = ""
    @Published var newTopicName: String = ""
    @Published var newContentText: String = ""
    @Published var newQuestionText: String = ""
    @Published var newAnswerText: String = ""
    @Published var selectedClassic = true
    @Published var selectedTest = true
    
    var selectedQuestionTypes: [String] {
        var types: [String] = []
        if selectedClassic { types.append("classic") }
        if selectedTest { types.append("test") }
        return types
    }
    
    let repository: LessonRepository
    public var currentUserId: String {
        didSet {
            if !currentUserId.isEmpty {
                loadLessons()
            }
        }
    }
    
    // MARK: - Init
    init(repository: LessonRepository = FirestoreLessonRepository(),
         currentUserId: String) {
        self.repository = repository
        self.currentUserId = currentUserId
    }
    
    // MARK: - LESSONS
    func loadLessons() {
        Task {
            await fetchLessons()
        }
    }
    
    func addLesson() {
        guard !newLessonName.isEmpty else { return }
        Task {
            await createLesson(name: newLessonName)
        }
    }
    
    func deleteLesson(_ lessonId: String) {
        Task {
            await removeLesson(lessonId)
        }
    }
    
    private func fetchLessons() async {
        guard !currentUserId.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        do {
            lessons = try await repository.fetchLessons(for: currentUserId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    private func createLesson(name: String) async {
        guard !currentUserId.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        let lesson = Lesson(userId: currentUserId, name: name)
        do {
            try await repository.addLesson(lesson)
            await fetchLessons()
            newLessonName = ""
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    private func removeLesson(_ lessonId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            try await repository.deleteLesson(lessonId)
            await fetchLessons()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    // MARK: - TOPICS
    func loadTopics(for lessonId: String) {
        Task {
            await fetchTopics(lessonId: lessonId)
        }
    }
    
    func addTopic(to lessonId: String) {
        guard !newTopicName.isEmpty else { return }
        Task {
            await createTopic(lessonId: lessonId, name: newTopicName)
        }
    }
    
    func deleteTopic(_ topicId: String, for lessonId: String) {
        Task {
            await removeTopic(topicId: topicId, lessonId: lessonId)
        }
    }
    
    private func fetchTopics(lessonId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            topics = try await repository.fetchTopics(for: lessonId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    private func createTopic(lessonId: String, name: String) async {
        isLoading = true
        errorMessage = nil
        let topic = Topic(lessonId: lessonId, name: name)
        do {
            try await repository.addTopic(topic)
            await fetchTopics(lessonId: lessonId)
            newTopicName = ""
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    private func removeTopic(topicId: String, lessonId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            try await repository.deleteTopic(topicId)
            await fetchTopics(lessonId: lessonId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    // MARK: - CONTENTS
    func loadContents(for topicId: String) {
        Task {
            await fetchContents(topicId: topicId)
        }
    }
    
    func addContent(to topicId: String) {
        guard !newContentText.isEmpty else { return }
        Task {
            await createContent(topicId: topicId, text: newContentText)
        }
    }
    
    
    
    func generateContent(for lesson: Lesson, topic: Topic, prompt: String, completion: @escaping () -> Void) {
        Task {
            isLoading = true
            defer {
                isLoading = false
                completion()
            }

            do {
                // Get current user's education level
                let authViewModel = AuthViewModel()
                try await authViewModel.loadCurrentUser()
                let educationLevel = authViewModel.currentUser?.educationLevel ?? .highschool
                
                let generatedText = try await GeminiService.shared.generateLearningContent(
                    lesson: lesson.name,
                    topic: topic.name,
                    userPrompt: prompt,
                    educationLevel: educationLevel
                )
                let content = TopicContent(topicId: topic.id, text: generatedText)
                try await repository.addContent(content)
                await fetchContents(topicId: topic.id)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    
    
    func deleteContent(_ contentId: String, for topicId: String) {
        Task {
            await removeContent(contentId: contentId, topicId: topicId)
        }
    }
    
    private func fetchContents(topicId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            contents = try await repository.fetchContents(for: topicId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    private func createContent(topicId: String, text: String) async {
        isLoading = true
        errorMessage = nil
        let content = TopicContent(topicId: topicId, text: text)
        do {
            try await repository.addContent(content)
            await fetchContents(topicId: topicId)
            newContentText = ""
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    private func removeContent(contentId: String, topicId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            try await repository.deleteContent(contentId)
            await fetchContents(topicId: topicId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    // MARK: - QUESTION SETS
    func loadQuestionSets(for topicId: String) {
        Task {
            await fetchQuestionSets(topicId: topicId)
        }
    }
    
    func addQuestionSet(to topicId: String, name: String, description: String? = nil) {
        Task {
            await createQuestionSet(topicId: topicId, name: name, description: description)
        }
    }
    
    func deleteQuestionSet(_ questionSetId: String, for topicId: String) {
        Task {
            await removeQuestionSet(questionSetId: questionSetId, topicId: topicId)
        }
    }
    
    private func fetchQuestionSets(topicId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            questionSets = try await repository.fetchQuestionSets(for: topicId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    private func createQuestionSet(topicId: String, name: String, description: String?) async {
        isLoading = true
        errorMessage = nil
        let questionSet = QuestionSet(topicId: topicId, name: name, description: description)
        do {
            try await repository.addQuestionSet(questionSet)
            await fetchQuestionSets(topicId: topicId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    private func removeQuestionSet(questionSetId: String, topicId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            try await repository.deleteQuestionSet(questionSetId)
            await fetchQuestionSets(topicId: topicId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    // MARK: - QUESTIONS (Updated for Question Sets)
    func loadQuestions(for questionSetId: String, in topicId: String) {
        Task {
            await fetchQuestionsInSet(questionSetId: questionSetId, topicId: topicId)
        }
    }
    
    private func fetchQuestionsInSet(questionSetId: String, topicId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            questions = try await repository.fetchQuestions(for: questionSetId, in: topicId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func addQuestion(to topicId: String) {
        guard !newQuestionText.isEmpty, !newAnswerText.isEmpty else { return }
        Task {
            await createQuestion(topicId: topicId, question: newQuestionText, answer: newAnswerText)
        }
    }
    
    func deleteQuestion(_ questionId: String, for topicId: String) {
        Task {
            await removeQuestion(questionId: questionId, topicId: topicId)
        }
    }
    
    private func fetchQuestions(topicId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            questions = try await repository.fetchQuestions(for: topicId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    private func createQuestion(topicId: String, question: String, answer: String) async {
        isLoading = true
        errorMessage = nil
        
        
        let newQ = Question(
            topicId: topicId,
            questionSetId: nil,
            questionText: question,
            answerText: answer,
            type: .classic
        )
        do {
            try await repository.addQuestion(newQ)
            await fetchQuestions(topicId: topicId)
            newQuestionText = ""
            newAnswerText = ""
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    private func removeQuestion(questionId: String, topicId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            try await repository.deleteQuestion(questionId)
            await fetchQuestions(topicId: topicId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    // MARK: - AI Generation Methods
    func generateAIQuestions(for lesson: Lesson, topic: Topic, userPrompt: String, count: Int, questionSetId: String, selectedQuestionTypes: [QuestionType], completion: @escaping () -> Void) {
        Task {
            isLoading = true
            defer {
                isLoading = false
                completion()
            }
            
            do {
                let authViewModel = AuthViewModel()
                try await authViewModel.loadCurrentUser()
                let educationLevel = authViewModel.currentUser?.educationLevel ?? .highschool
                
                let pairs = try await GeminiService.shared.generateQuestions(
                    lesson: lesson.name,
                    topic: topic,
                    userPrompt: userPrompt,
                    count: count,
                    educationLevel: educationLevel,
                    questionTypes: selectedQuestionTypes
                )
                
                for pair in pairs {
                    //let questionHtml = CreateHtml.createHTML(with: pair.question)
                    //let answerHtml = CreateHtml.createHTML(with: pair.answer)
                    
                    let question = Question(
                        topicId: topic.id,
                        questionSetId: questionSetId,
                        questionText: pair.question,
                        answerText: pair.answer,
                        type: selectedQuestionTypes.first ?? .classic
                    )
                    try await repository.addQuestion(question)
                }
                await fetchQuestionsInSet(questionSetId: questionSetId, topicId: topic.id)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
