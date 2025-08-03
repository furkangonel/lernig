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
                TextField("Topic Name", text: $topicName)
            }
            .navigationTitle("Add Topic")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.newTopicName = topicName
                        viewModel.addTopic(to: lesson.id)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
    }
}
