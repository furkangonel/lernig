//
//  AddTopicView.swift
//  lernig
//
//  Created by Furkan Gönel on 30.07.2025.
//


import SwiftUI

struct AddTopicView: View {
    let lesson: Lesson
    @ObservedObject var viewModel: LessonViewModel
    @Environment(\.dismiss) var dismiss
    @State private var topicName: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Topic Name")) {
                    TextField("Topic Name", text: $topicName)
                }
            }
            .navigationTitle("Add Topic")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.newTopicName = topicName
                        viewModel.addTopic(to: lesson.id)
                        dismiss()
                    }
                    .font(.custom("SFProRounded-Bold", size: 16.0))
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                    .font(.custom("SFProRounded-Regular", size: 16.0))
                }
            }
            //.foregroundColor(Color("c_0"))
            
        }
    }
}



#Preview {
    let dummyLesson = Lesson(
        id: "12",
        userId: "1234",
        name: "Math",
        createdAt: Date()
    )
    
    let dummyViewModel = LessonViewModel(currentUserId: "testUser")
    
    return AddTopicView(lesson: dummyLesson, viewModel: dummyViewModel)
}
