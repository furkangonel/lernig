//
//  ProfilePage.swift
//  lernig
//
//  Created by Furkan Gönel on 30.07.2025.
//


import SwiftUI

struct ProfilePage: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var lessonViewModel = LessonViewModel(currentUserId: "1")
    @State private var showingDeleteAccountAlert = false
    @State private var showingLogoutAlert = false
    @State private var showingEditProfile = false
    @State private var showAbout = false

    
    var body: some View {
        NavigationStack {
                VStack(spacing: 24) {
                    ScrollView {
                        
                    if let user = authViewModel.currentUser {
                        profileHeader(user: user)
                        quickActions()
                        accountActions()
                    }
                }
            }
            .navigationTitle("Profile")
            .toolbar {
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
            .sheet(isPresented: $showAbout) {
                AboutLernigView()
            }
            
            .alert("Sign Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    authViewModel.logout()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .alert("Delete Account", isPresented: $showingDeleteAccountAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    // Implement account deletion
                }
            } message: {
                Text("This action cannot be undone. All your data will be permanently deleted.")
            }
            
            
        }
    }
    
    
    
    struct ActionButton: View {
        let title: String
        let subtitle: String
        let icon: String
        let color: String
        let action: () -> Void
        
        var body: some View {
            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                action()
            }) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(Color(color))
                        .frame(width: 32)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.custom("SFProRounded-Semibold", size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Text(subtitle)
                            .font(.custom("SFProRounded-Semibold", size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - User Profile Header
    @ViewBuilder
    private func profileHeader(user: User) -> some View {
        VStack(spacing: 16) {
            Circle()
                .fill(Color("c_3"))
                .frame(width: 100, height: 100)
                .overlay(
                    Text(String(user.name.prefix(1)).uppercased())
                        .font(.custom("SFProRounded-Medium", size: 36))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            VStack(spacing: 4) {
                Text(user.name)
                    .font(.custom("SFProRounded-Regular", size: 24))
                    .fontWeight(.bold)
                
                Text("@\(user.username)")
                    .font(.custom("SFProRounded-Regular", size: 16))
                    .foregroundColor(.secondary)
                
                Text(user.email)
                    .font(.custom("SFProRounded-Regular", size: 14))
                    .foregroundColor(.secondary)
                
                // Education Level Badge
                Text(user.educationLevel.rawValue.capitalized)
                    .font(.custom("SFProRounded-Regular", size: 12))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color("c_3").opacity(0.2))
                    .foregroundColor(Color("c_3"))
                    .cornerRadius(12)
            }
            Button("Edit Profile") {
                showingEditProfile = true
            }
            .font(.custom("SFProRounded-Regular", size: 14))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color("c_3").opacity(0.1))
            .foregroundColor(Color("c_3"))
            .cornerRadius(12)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
        .padding(.bottom, 64)
    }

    
    //MARK: - Quick Actions
    @ViewBuilder
    private func quickActions() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.custom("SFProRounded-Semibold", size: 20))
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                
                ActionButton(
                    title: "Export Data",
                    subtitle: "Download your lessons and progress",
                    icon: "square.and.arrow.up",
                    color: "c_3",
                    action: { exportData() }
                )
                
                ActionButton(
                    title: "Share App",
                    subtitle: "Invite friends to join Lernig",
                    icon: "square.and.arrow.up.on.square",
                    color: "c_3",
                    action: { shareApp() }
                )
                
                ActionButton(
                    title: "About Lernig",
                    subtitle: "Version 1.0.0",
                    icon: "info.circle",
                    color: "c_3",
                    action: { showAbout = true }
                )
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 36)
    }

    
    //MARK: - Account Actions
    @ViewBuilder
    private func accountActions() -> some View {
        VStack(alignment: .leading) {
            Text("Account")
                .font(.custom("SFProRounded-Semibold", size: 20))
                .fontWeight(.semibold)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            
            // sign-out & delete buttons
            VStack {
                    Button {
                        showingLogoutAlert = true
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                            .font(.custom("SFProRounded-Semibold", size: 16.0))
                            .foregroundColor(Color("b_w"))
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle(color: "w_b"))
                    
                    
                    Button {
                        showingDeleteAccountAlert = true
                    } label: {
                        Label("Delete Account", systemImage: "trash")
                            .font(.custom("SFProRounded-Semibold", size: 16.0))
                            .foregroundColor(Color("c_2"))
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle(color: "w_b"))
            }
            .padding(.horizontal)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .gray.opacity(0.1), radius: 5)
        }    }
    
    

    private func exportData() {
        // Basic haptic feedback without HapticManager
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        print("Export data tapped")
    }
    
    private func shareApp() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        print("Share app tapped")
    }
    
}




#Preview {
    let viewModel = AuthViewModel()
    viewModel.currentUser = User(
        id: "123",
        name: "Furkan Gönel",
        username: "furkangonel",
        email: "furkan@example.com",
        educationLevel: .university
    )
    
    return ProfilePage()
        .environmentObject(viewModel)
}
