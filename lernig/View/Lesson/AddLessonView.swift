//
//  AddLessonView.swift
//  lernig
//
//  Created by Furkan Gönel on 30.07.2025.
//


import SwiftUI

struct AddLessonView: View {
    @ObservedObject var viewModel: LessonViewModel
    @Environment(\.dismiss) var dismiss
    @State private var lessonName: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Lesson Information")) {
                    TextField("Lesson Name", text: $lessonName)
                        .font(.custom("SFProRounded-Regular", size: 16))
                }
            }
            .navigationTitle("Add Lesson")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.newLessonName = lessonName
                        viewModel.addLesson()
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
    let dummyViewModel = LessonViewModel(currentUserId: "testUser")
    return AddLessonView(viewModel: dummyViewModel)
}
