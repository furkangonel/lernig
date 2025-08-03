//
//  QuestionsPage.swift
//  lernig
//
//  Created by Furkan Gönel on 30.07.2025.
//


import SwiftUI

struct QuestionsPage: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = LessonViewModel(currentUserId: "")
    @State private var allQuestions: [Question] = []
    @State private var isLoading = false
    @State private var showingQuiz = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView("Loading questions...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if allQuestions.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 64))
                            .foregroundColor(.secondary)
                        Text("No questions yet")
                            .font(.custom("AppleMyungjo", size: 24))
                            .foregroundColor(.secondary)
                        Text("Add topics and create questions to see them here")
                            .font(.custom("AppleMyungjo", size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        Section(header: Text("All Questions (\(allQuestions.count))")) {
                            ForEach(allQuestions, id: \.id) { question in
                                QuestionRowView(question: question)
                            }
                        }
                    }
                    .refreshable {
                        loadAllQuestions()
                    }
                }
            }
            .navigationTitle("Questions")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Start Quiz") {
                        showingQuiz = true
                    }
                    .disabled(allQuestions.isEmpty)
                }
            }
            .onAppear {
                if let userId = authViewModel.currentUser?.id {
                    viewModel.currentUserId = userId
                    loadAllQuestions()
                }
            }
            .sheet(isPresented: $showingQuiz) {
                QuizView(questions: allQuestions)
            }
        }
    }
    
    private func loadAllQuestions() {
        
        guard let userId = authViewModel.currentUser?.id else { return }
        
        isLoading = true
        Task {
            do {
                let lessons = try await viewModel.repository.fetchLessons(for: userId)
                var questions: [Question] = []
                
                for lesson in lessons {
                    let topics = try await viewModel.repository.fetchTopics(for: lesson.id)
                    for topic in topics {
                        let topicQuestions = try await viewModel.repository.fetchQuestions(for: topic.id)
                        questions.append(contentsOf: topicQuestions)
                    }
                }
                
                await MainActor.run {
                    self.allQuestions = questions
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
}

struct QuestionRowView: View {
    let question: Question
    @State private var showAnswer = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(question.questionText)
                .font(.custom("AppleMyungjo", size: 16))
                .fontWeight(.medium)
            
            if showAnswer {
                Text(question.answerText)
                    .font(.custom("AppleMyungjo", size: 14))
                    .foregroundColor(.secondary)
                    .padding(.leading, 16)
            }
            
            Button(showAnswer ? "Hide Answer" : "Show Answer") {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showAnswer.toggle()
                }
            }
            .font(.custom("AppleMyungjo", size: 12))
            .foregroundColor(.blue)
        }
        .padding(.vertical, 4)
    }
}

struct QuizView: View {
    let questions: [Question]
    @Environment(\.dismiss) var dismiss
    @State private var currentQuestionIndex = 0
    @State private var showAnswer = false
    @State private var score = 0
    @State private var quizCompleted = false
    
    var currentQuestion: Question {
        questions[currentQuestionIndex]
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if !quizCompleted {
                    // Progress
                    ProgressView(value: Double(currentQuestionIndex + 1), total: Double(questions.count))
                        .padding(.horizontal)
                    
                    Text("Question \(currentQuestionIndex + 1) of \(questions.count)")
                        .font(.custom("AppleMyungjo", size: 16))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Question
                    Text(currentQuestion.questionText)
                        .font(.custom("AppleMyungjo", size: 24))
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    if showAnswer {
                        Text(currentQuestion.answerText)
                            .font(.custom("AppleMyungjo", size: 18))
                            .foregroundColor(.secondary)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                    }
                    
                    Spacer()
                    
                    // Buttons
                    VStack(spacing: 16) {
                        if !showAnswer {
                            Button("Show Answer") {
                                withAnimation {
                                    showAnswer = true
                                }
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        } else {
                            HStack(spacing: 16) {
                                Button("Incorrect") {
                                    nextQuestion()
                                }
                                .buttonStyle(.bordered)
                                
                                Button("Correct") {
                                    score += 1
                                    nextQuestion()
                                }
                                .buttonStyle(PrimaryButtonStyle())
                            }
                        }
                    }
                } else {
                    // Quiz Results
                    VStack(spacing: 24) {
                        Text("Quiz Completed! 🎉")
                            .font(.custom("AppleMyungjo", size: 32))
                            .fontWeight(.bold)
                        
                        Text("Your Score: \(score)/\(questions.count)")
                            .font(.custom("AppleMyungjo", size: 24))
                        
                        let percentage = Double(score) / Double(questions.count) * 100
                        Text("\(Int(percentage))%")
                            .font(.custom("AppleMyungjo", size: 48))
                            .fontWeight(.bold)
                            .foregroundColor(percentage >= 70 ? .green : percentage >= 50 ? .orange : .red)
                        
                        Button("Close") {
                            dismiss()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                }
            }
            .padding()
            .navigationTitle("Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func nextQuestion() {
        if currentQuestionIndex + 1 < questions.count {
            withAnimation {
                currentQuestionIndex += 1
                showAnswer = false
            }
        } else {
            withAnimation {
                quizCompleted = true
            }
        }
    }
}

#Preview {
    QuestionsPage()
        .environmentObject(AuthViewModel())
}
