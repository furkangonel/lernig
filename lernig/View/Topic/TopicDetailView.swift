//
//  TopicDetailView.swift
//  lernig
//
//  Created by Furkan Gönel on 30.07.2025.
//

import SwiftUI

struct TopicDetailView: View {
    @ObservedObject var viewModel: LessonViewModel
    @ObservedObject var authViewModel: AuthViewModel
    @State private var prompt: String = ""
    @State private var isLoading = false
    @State private var selectedTab = 0
    @State private var selectedQuestionTypes: [QuestionType] = [.classic]
    
    var topic: Topic
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab Selector
            Picker("View", selection: $selectedTab) {
                Text("Content").tag(0)
                Text("Questions").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()
            
            TabView(selection: $selectedTab) {
                // Content Tab
                contentView
                    .tag(0)
                
                // Questions Tab
                questionSetsView
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle(topic.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadContents(for: topic.id)
            viewModel.loadQuestionSets(for: topic.id)
        }
    }
    
    private var contentView: some View {
        VStack(spacing: 16) {
            if let content = viewModel.contents.first(where: { $0.topicId == topic.id })?.text, !content.isEmpty {
                ScrollView {
                    Text(content)
                        .font(.custom("AppleMyungjo", size: 16))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            } else {
                Spacer()
                
                VStack(spacing: 16) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("No content yet")
                        .font(.custom("AppleMyungjo", size: 20))
                        .foregroundColor(.secondary)
                    
                    Text("Generate content for this topic")
                        .font(.custom("AppleMyungjo", size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    TextField("What would you like to learn about?", text: $prompt)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.custom("AppleMyungjo", size: 16))
                    
                    HStack {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        
                        Button(action: generateContent) {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("Generate Content")
                            }
                            .font(.custom("AppleMyungjo", size: 16))
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(prompt.isEmpty || isLoading)
                    }
                }
                .padding()
            }
        }
    }
    
    private var questionSetsView: some View {
        VStack {
            if viewModel.questionSets.filter({ $0.topicId == topic.id }).isEmpty {
                // Empty state
                Spacer()
                
                VStack(spacing: 16) {
                    Image(systemName: "list.bullet.rectangle")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("No question sets yet")
                        .font(.custom("AppleMyungjo", size: 20))
                        .foregroundColor(.secondary)
                    
                    Text("Create question sets to organize your questions")
                        .font(.custom("AppleMyungjo", size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                Button("Create Question Set") {
                    // Create default first question set
                    viewModel.addQuestionSet(to: topic.id, name: "Question Set 1", description: "First set of questions for \(topic.name)")
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding()
            } else {
                // Question sets list
                List {
                    ForEach(viewModel.questionSets.filter { $0.topicId == topic.id }) { questionSet in
                        NavigationLink(destination: QuestionSetDetailView(questionSet: questionSet, viewModel: viewModel, authViewModel: authViewModel)) {
                            QuestionSetRowView(questionSet: questionSet, viewModel: viewModel)
                        }
                    }
                    .onDelete(perform: deleteQuestionSets)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: addNewQuestionSet) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }
    }
    
    private func generateContent() {
        isLoading = true
        
        // Find the lesson for this topic
        let lesson = viewModel.lessons.first { lesson in
            viewModel.topics.contains { $0.lessonId == lesson.id && $0.id == topic.id }
        } ?? Lesson(userId: viewModel.currentUserId, name: "Unknown Lesson")
        
        viewModel.generateContent(for: lesson, topic: topic, prompt: prompt) {
            isLoading = false
            prompt = ""
        }
    }
    
    private func addNewQuestionSet() {
        let setNumber = viewModel.questionSets.filter { $0.topicId == topic.id }.count + 1
        viewModel.addQuestionSet(
            to: topic.id,
            name: "Question Set \(setNumber)",
            description: "Question set \(setNumber) for \(topic.name)"
        )
    }
    
    private func deleteQuestionSets(offsets: IndexSet) {
        let setsToDelete = offsets.map {
            viewModel.questionSets.filter { $0.topicId == topic.id }[$0]
        }
        for questionSet in setsToDelete {
            viewModel.deleteQuestionSet(questionSet.id, for: topic.id)
        }
    }
}

struct QuestionSetRowView: View {
    let questionSet: QuestionSet
    @ObservedObject var viewModel: LessonViewModel
    @State private var questionCount = 0
    @State private var classicCount = 0
    @State private var testCount = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "list.bullet.rectangle.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 16))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(questionSet.name)
                        .font(.custom("AppleMyungjo", size: 16))
                        .fontWeight(.medium)
                    
                    HStack(spacing: 12) {
                        Text("\(questionCount) questions")
                            .font(.custom("AppleMyungjo", size: 12))
                            .foregroundColor(.secondary)
                        
                        if classicCount > 0 {
                            Text("\(classicCount) classic")
                                .font(.custom("AppleMyungjo", size: 10))
                                .foregroundColor(.blue)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(3)
                        }
                        
                        if testCount > 0 {
                            Text("\(testCount) test")
                                .font(.custom("AppleMyungjo", size: 10))
                                .foregroundColor(.green)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(3)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            if let description = questionSet.description, !description.isEmpty {
                Text(description)
                    .font(.custom("AppleMyungjo", size: 12))
                    .foregroundColor(.secondary)
                    .padding(.leading, 24)
            }
            
            Text("Created: \(questionSet.createdAt.formatted(date: .abbreviated, time: .omitted))")
                .font(.custom("AppleMyungjo", size: 10))
                .foregroundColor(.secondary)
                .padding(.leading, 24)
        }
        .padding(.vertical, 4)
        .onAppear {
            loadQuestionCount()
        }
    }
    
    private func loadQuestionCount() {
        Task {
            do {
                let questions = try await viewModel.repository.fetchQuestions(for: questionSet.id, in: questionSet.topicId)
                await MainActor.run {
                    questionCount = questions.count
                    classicCount = questions.filter { $0.type == .classic }.count
                    testCount = questions.filter { $0.type == .test }.count
                }
            } catch {
                await MainActor.run {
                    questionCount = 0
                    classicCount = 0
                    testCount = 0
                }
            }
        }
    }
}

#Preview {
    let dummyLesson = Lesson(userId: "testUser", name: "Sample Lesson")
    let dummyViewModel = LessonViewModel(repository: MockLessonRepository(), currentUserId: "testUser")
    
    // Preview için mock kullanıcı oluşturuyoruz
    let authViewModel = AuthViewModel()
    authViewModel.currentUser = User(
        id: "preview-user",
        name: "Preview User",
        username: "preview",
        email: "preview@example.com",
        educationLevel: .highschool
    )
    
    return NavigationStack {
        TopicListPage(lesson: dummyLesson, viewModel: dummyViewModel)
            .environmentObject(authViewModel)
    }
}
