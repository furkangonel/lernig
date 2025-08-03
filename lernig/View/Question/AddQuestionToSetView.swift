//
//  AddQuestionToSetView.swift
//  lernig
//
//  Created by Furkan Gönel on 2.08.2025.
//


import SwiftUI

// MARK: - Add Question View (Updated)
struct AddQuestionToSetView: View {
    let questionSet: QuestionSet
    @ObservedObject var viewModel: LessonViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedQuestionType: QuestionType = .classic
    @State private var questionText: String = ""
    @State private var answerText: String = ""
    
    // Test question specific
    @State private var optionA: String = ""
    @State private var optionB: String = ""
    @State private var optionC: String = ""
    @State private var optionD: String = ""
    @State private var correctAnswer: String = "A"
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Question Type")) {
                    Picker("Type", selection: $selectedQuestionType) {
                        Text("Classic Q&A").tag(QuestionType.classic)
                        Text("Multiple Choice").tag(QuestionType.test)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Question")) {
                    TextField("Enter your question", text: $questionText, axis: .vertical)
                        .font(.custom("AppleMyungjo", size: 16))
                        .lineLimit(3...6)
                }
                
                if selectedQuestionType == .classic {
                    Section(header: Text("Answer")) {
                        TextField("Enter the answer", text: $answerText, axis: .vertical)
                            .font(.custom("AppleMyungjo", size: 16))
                            .lineLimit(3...8)
                    }
                } else {
                    Section(header: Text("Options")) {
                        TextField("Option A", text: $optionA)
                            .font(.custom("AppleMyungjo", size: 16))
                        TextField("Option B", text: $optionB)
                            .font(.custom("AppleMyungjo", size: 16))
                        TextField("Option C", text: $optionC)
                            .font(.custom("AppleMyungjo", size: 16))
                        TextField("Option D", text: $optionD)
                            .font(.custom("AppleMyungjo", size: 16))
                    }
                    
                    Section(header: Text("Correct Answer")) {
                        Picker("Correct Answer", selection: $correctAnswer) {
                            Text("A").tag("A")
                            Text("B").tag("B")
                            Text("C").tag("C")
                            Text("D").tag("D")
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    Section(header: Text("Explanation (Optional)")) {
                        TextField("Explain why this answer is correct", text: $answerText, axis: .vertical)
                            .font(.custom("AppleMyungjo", size: 16))
                            .lineLimit(2...5)
                    }
                }
            }
            .navigationTitle("Add Question")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveQuestion()
                    }
                    .disabled(!isFormValid)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        if questionText.isEmpty { return false }
        
        if selectedQuestionType == .classic {
            return !answerText.isEmpty
        } else {
            return !optionA.isEmpty && !optionB.isEmpty && !optionC.isEmpty && !optionD.isEmpty
        }
    }
    
    private func saveQuestion() {
        Task {
            let testData: TestQuestionData?
            
            if selectedQuestionType == .test {
                let correctIndex = switch correctAnswer {
                case "A": 0
                case "B": 1
                case "C": 2
                case "D": 3
                default: 0
                }
                
                testData = TestQuestionData(
                    options: [optionA, optionB, optionC, optionD],
                    correctOptionIndex: correctIndex
                )
            } else {
                testData = nil
            }
            
            let question = Question(
                id: UUID().uuidString,
                topicId: questionSet.topicId,
                questionSetId: questionSet.id,
                questionText: questionText,
                answerText: answerText,
                type: selectedQuestionType,
                testData: testData,
                createdAt: Date()
            )
            try await viewModel.repository.addQuestion(question)
            viewModel.loadQuestions(for: questionSet.id, in: questionSet.topicId)
            dismiss()
        }
    }
}
