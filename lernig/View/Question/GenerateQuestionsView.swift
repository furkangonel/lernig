//
//  GenerateQuestionsView.swift
//  lernig
//
//  Created by Furkan Gönel on 2.08.2025.
//

import SwiftUI


struct GenerateQuestionsView: View {
    let questionSet: QuestionSet
    @ObservedObject var viewModel: LessonViewModel
    @ObservedObject var authViewModel: AuthViewModel
    @Binding var isPresented: Bool
    
    @State private var questionPrompt: String = ""
    @State private var questionCount: Int = 3
    @State private var selectedQuestionTypes: Set<QuestionType> = [.classic]
    @State private var isGeneratingQuestions = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Question Details")) {
                    TextField("What kind of questions?", text: $questionPrompt, axis: .vertical)
                        .font(.custom("AppleMyungjo", size: 16))
                        .lineLimit(2...4)
                }
                
                Section(header: Text("Question Types")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle(isOn: Binding(
                            get: { selectedQuestionTypes.contains(.classic) },
                            set: { isOn in
                                if isOn {
                                    selectedQuestionTypes.insert(.classic)
                                } else {
                                    selectedQuestionTypes.remove(.classic)
                                }
                            }
                        )) {
                            HStack {
                                Image(systemName: "text.bubble")
                                    .foregroundColor(.blue)
                                Text("Classic Q&A")
                                    .font(.custom("AppleMyungjo", size: 16))
                            }
                        }
                        
                        Toggle(isOn: Binding(
                            get: { selectedQuestionTypes.contains(.test) },
                            set: { isOn in
                                if isOn {
                                    selectedQuestionTypes.insert(.test)
                                } else {
                                    selectedQuestionTypes.remove(.test)
                                }
                            }
                        )) {
                            HStack {
                                Image(systemName: "list.bullet")
                                    .foregroundColor(.green)
                                Text("Multiple Choice")
                                    .font(.custom("AppleMyungjo", size: 16))
                            }
                        }
                    }
                }
                
                Section(header: Text("Number of Questions")) {
                    VStack(spacing: 8) {
                        Slider(value: Binding(get: {
                            Double(questionCount)
                        }, set: { newValue in
                            questionCount = Int(newValue)
                        }), in: 1...15, step: 1)
                        
                        Text("\(questionCount) Question(s)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Generate Questions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Generate") {
                        generateQuestions()
                    }
                    .disabled(questionPrompt.isEmpty || selectedQuestionTypes.isEmpty || isGeneratingQuestions)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        isPresented = false
                    }
                }
            }
            .overlay {
                if isGeneratingQuestions {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Generating questions...")
                            .font(.custom("AppleMyungjo", size: 16))
                    }
                    .padding(24)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    private func generateQuestions() {
        isGeneratingQuestions = true
        
        Task {
            do {
                let lesson = viewModel.lessons.first { lesson in
                    viewModel.topics.contains { $0.lessonId == lesson.id && $0.id == questionSet.topicId }
                } ?? Lesson(userId: viewModel.currentUserId, name: "Unknown Lesson")
                
                let topic = viewModel.topics.first { $0.id == questionSet.topicId } ?? Topic(lessonId: lesson.id, name: "Unknown Topic")
               
                let pairs = try await GeminiService.shared.generateQuestions(
                    lesson: lesson.name,
                    topic: topic,
                    userPrompt: questionPrompt,
                    count: questionCount,
                    educationLevel: authViewModel.currentUser?.educationLevel ?? .highschool,
                    questionTypes: Array(selectedQuestionTypes)
                )
                
                for pair in pairs {
                    let question = Question(
                        id: UUID().uuidString,
                        topicId: questionSet.topicId,
                        questionSetId: questionSet.id,
                        questionText: pair.question,
                        answerText: pair.answer,
                        type: pair.type,
                        testData: pair.testData,
                        createdAt: Date()
                    )
                    try await viewModel.repository.addQuestion(question)
                }
                
                await MainActor.run {
                    isGeneratingQuestions = false
                    isPresented = false
                    viewModel.loadQuestions(for: questionSet.id, in: questionSet.topicId)
                }
            } catch {
                await MainActor.run {
                    isGeneratingQuestions = false
                    viewModel.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
