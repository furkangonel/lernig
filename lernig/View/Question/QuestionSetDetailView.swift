//
//  QuestionSetDetailView.swift
//  lernig
//
//  Created by Furkan Gönel on 30.07.2025.
//

import SwiftUI

struct QuestionSetDetailView: View {
    let questionSet: QuestionSet
    @ObservedObject var viewModel: LessonViewModel
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var questionPrompt: String = ""
    @State private var questionCount: Int = 3
    @State private var selectedQuestionTypes: Set<QuestionType> = [.classic]
    @State private var isGeneratingQuestions = false
    @State private var isPresentingAddQuestion = false
    @State private var showingQuiz = false
    @State private var selectedViewTab = 0 // 0: All, 1: Classic, 2: Test
    @State private var showDeleteAlert = false
    @State private var showGenerateForm = false
    
    // Soruları tip bazında filtreliyoruz
    var filteredQuestions: [Question] {
        let allQuestions = viewModel.questions.filter { $0.questionSetId == questionSet.id }
        
        switch selectedViewTab {
        case 1: // Classic only
            return allQuestions.filter { $0.type == .classic }
        case 2: // Test only
            return allQuestions.filter { $0.type == .test }
        default: // All questions
            return allQuestions
        }
    }
    
    var body: some View {
        VStack {
            if viewModel.questions.filter({ $0.questionSetId == questionSet.id }).isEmpty {
                // Empty State
                emptyStateView
            } else {
                // Questions View with Tabs
                questionsView
            }
        }
        .navigationTitle(questionSet.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Add Manually") {
                        isPresentingAddQuestion = true
                    }
                    Button("Generate Questions") {
                        showGenerateForm = true
                    }
                    Button("Delete Question Set", role: .destructive) {
                        showDeleteAlert = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert("Delete Question Set", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteQuestionSet()
            }
        } message: {
            Text("This will permanently delete this question set and all its questions.")
        }
        .onAppear {
            loadQuestions()
        }
        .sheet(isPresented: $isPresentingAddQuestion) {
            AddQuestionToSetView(questionSet: questionSet, viewModel: viewModel)
        }
        .sheet(isPresented: $showingQuiz) {
            QuizView(questions: filteredQuestions)
        }
        .sheet(isPresented: $showGenerateForm) {
            GenerateQuestionsView(
                questionSet: questionSet,
                viewModel: viewModel,
                authViewModel: authViewModel,
                isPresented: $showGenerateForm
            )
        }
    }
    
    private var emptyStateView: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)
                
                Text("No questions yet")
                    .font(.custom("AppleMyungjo", size: 20))
                    .foregroundColor(.secondary)
                
                Text("Generate questions for this set")
                    .font(.custom("AppleMyungjo", size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                Button("Generate Questions") {
                    showGenerateForm = true
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Button("Add Manually") {
                    isPresentingAddQuestion = true
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
    }
    
    private var questionsView: some View {
        VStack {
            // Tab selector for question types
            Picker("Question Type", selection: $selectedViewTab) {
                Text("All (\(viewModel.questions.filter { $0.questionSetId == questionSet.id }.count))").tag(0)
                Text("Classic (\(viewModel.questions.filter { $0.questionSetId == questionSet.id && $0.type == .classic }.count))").tag(1)
                Text("Test (\(viewModel.questions.filter { $0.questionSetId == questionSet.id && $0.type == .test }.count))").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            List {
                Section(header:
                    HStack {
                        Text("\(filteredQuestions.count) Questions")
                        Spacer()
                        Button("Start Quiz") {
                            showingQuiz = true
                        }
                        .font(.caption)
                        .buttonStyle(.borderless)
                        .disabled(filteredQuestions.isEmpty)
                    }
                ) {
                    ForEach(filteredQuestions) { question in
                        if question.type == .classic {
                            ClassicQuestionCardView(question: question)
                        } else if question.type == .test {
                            TestQuestionCardView(question: question)
                        }
                    }
                    .onDelete(perform: deleteQuestions)
                }
            }
            
            // Floating Action Button for adding more questions
            HStack {
                Spacer()
                Button(action: {
                    showGenerateForm = true
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add More")
                    }
                    .font(.custom("AppleMyungjo", size: 14))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(20)
                }
                .padding(.trailing)
                .padding(.bottom)
            }
        }
    }
    
    private func loadQuestions() {
        viewModel.loadQuestions(for: questionSet.id, in: questionSet.topicId)
    }
    
    private func deleteQuestions(offsets: IndexSet) {
        let questionsToDelete = offsets.map { filteredQuestions[$0] }
        for question in questionsToDelete {
            Task {
                try await viewModel.repository.deleteQuestion(question.id)
                viewModel.loadQuestions(for: questionSet.id, in: questionSet.topicId)
            }
        }
    }
    
    private func deleteQuestionSet() {
        Task {
            try await viewModel.repository.deleteQuestionSet(questionSet.id)
            await MainActor.run {
                dismiss()
            }
        }
    }
}



#Preview {
    let dummyQuestionSet = QuestionSet(topicId: "topic1", name: "Sample Question Set")
    let dummyViewModel = LessonViewModel(currentUserId: "testUser")
    let dummyAuthViewModel = AuthViewModel()
    NavigationStack {
        QuestionSetDetailView(questionSet: dummyQuestionSet, viewModel: dummyViewModel, authViewModel: dummyAuthViewModel)
    }
}
