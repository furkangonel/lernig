//
//  LessonsPage.swift
//  lernig
//
//  Created by Furkan Gönel on 30.07.2025.
//


import SwiftUI

struct LessonsPage: View {
    @ObservedObject var lessonViewModel: LessonViewModel
    @State private var isPresentingAddLesson = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(lessonViewModel.lessons, id: \.id) { lesson in
                    NavigationLink(destination: TopicListPage(lesson: lesson, viewModel: lessonViewModel)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(lesson.name)
                                .font(.custom("AppleMyungjo", size: 18))
                                .fontWeight(.medium)
                            Text("Created: \(lesson.createdAt.formatted(date: .abbreviated, time: .omitted))")
                                .font(.custom("AppleMyungjo", size: 12))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: deleteLessons)
            }
            .navigationTitle("Lessons")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { isPresentingAddLesson = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                lessonViewModel.loadLessons()
            }
            .refreshable {
                lessonViewModel.loadLessons()
            }
            .sheet(isPresented: $isPresentingAddLesson) {
                AddLessonView(viewModel: lessonViewModel)
            }
        }
    }
    
    private func deleteLessons(offsets: IndexSet) {
        let lessonsToDelete = offsets.map { lessonViewModel.lessons[$0] }
        for lesson in lessonsToDelete {
            lessonViewModel.deleteLesson(lesson.id)
        }
    }
}

#Preview {
    let dummyViewModel = LessonViewModel(repository: MockLessonRepository(), currentUserId: "1")
    return LessonsPage(lessonViewModel: dummyViewModel)
}
