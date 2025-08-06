//
//  EditProfileView.swift
//  lernig
//
//  Created by Furkan Gönel on 31.07.2025.
//


import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var educationLevel: EducationLevel = .highschool
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    
                    Picker("Education Level", selection: $educationLevel) {
                        ForEach(EducationLevel.allCases, id: \.self) { level in
                            Text(level.rawValue.capitalized).tag(level)
                        }
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await saveProfile()
                        }
                    }
                }
            }
            .font(.custom("SFProRounded-Medium", size: 16.0))
            .onAppear {
                if let user = authViewModel.currentUser {
                    name = user.name
                    email = user.email
                    educationLevel = user.educationLevel
                }
            }
        }
    }
    
    private func saveProfile() async {
        guard let user = authViewModel.currentUser else { return }
        
        let updatedUser = User(
            id: user.id,
            name: name,
            username: user.username,
            email: email,
            educationLevel: educationLevel
        )
        
        do {
            try await authViewModel.updateUserProfile(user: updatedUser)
            dismiss()
        } catch {
            print("Error updating profile: \(error)")
        }
    }
}
