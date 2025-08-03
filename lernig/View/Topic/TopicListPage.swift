//
//  TopicListPage.swift
//  lernig
//
//  Created by Furkan Gönel on 30.07.2025.
//


import SwiftUI

struct TopicListPage: View {
    let lesson: Lesson
    @ObservedObject var viewModel: LessonViewModel
    @State private var isPresentingAddTopic = false
    
    // Preview için mock authViewModel oluşturuyoruz
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.topics.filter { $0.lessonId == lesson.id }) { topic in
                // NavigationLink'i basitleştiriyoruz
                NavigationLink {
                    TopicDetailView(viewModel: viewModel,
                                  authViewModel: authViewModel,
                                  topic: topic)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(topic.name)
                            .font(.custom("AppleMyungjo", size: 16))
                            .fontWeight(.medium)
                        Text("Created: \(topic.createdAt.formatted(date: .abbreviated, time: .omitted))")
                            .font(.custom("AppleMyungjo", size: 12))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 2)
                }
            }
            .onDelete(perform: deleteTopics)
        }
        .navigationTitle(lesson.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { isPresentingAddTopic = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isPresentingAddTopic) {
            AddTopicView(lesson: lesson, viewModel: viewModel)
        }
        .onAppear {
            viewModel.loadTopics(for: lesson.id)
        }
        .refreshable {
            viewModel.loadTopics(for: lesson.id)
        }
    }
    
    private func deleteTopics(offsets: IndexSet) {
        let topicsToDelete = offsets.map { viewModel.topics[$0] }
        for topic in topicsToDelete {
            viewModel.deleteTopic(topic.id, for: lesson.id)
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
