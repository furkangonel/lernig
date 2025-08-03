//
//  SettingsView.swift
//  lernig
//
//  Created by Furkan Gönel on 30.07.2025.
//


import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingDeleteAccountAlert = false
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                // User Info Section
                Section {
                    if let user = authViewModel.currentUser {
                        HStack {
                            Circle()
                                .fill(Color("c_1"))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Text(String(user.name.prefix(1)).uppercased())
                                        .font(.custom("AppleMyungjo", size: 20))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.name)
                                    .font(.custom("AppleMyungjo", size: 18))
                                    .fontWeight(.medium)
                                
                                Text("@\(user.username)")
                                    .font(.custom("AppleMyungjo", size: 14))
                                    .foregroundColor(.secondary)
                                
                                Text(user.email)
                                    .font(.custom("AppleMyungjo", size: 12))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                // App Settings
                Section("App Settings") {
                    SettingsRow(
                        icon: "bell",
                        title: "Notifications",
                        subtitle: "Manage your notifications"
                    ) {
                        // Navigate to notifications settings
                    }
                    
                    SettingsRow(
                        icon: "paintbrush",
                        title: "Appearance",
                        subtitle: "Customize app appearance"
                    ) {
                        // Navigate to appearance settings
                    }
                    
                    SettingsRow(
                        icon: "square.and.arrow.up",
                        title: "Export Data",
                        subtitle: "Export your lessons and notes"
                    ) {
                        // Export functionality
                    }
                }
                
                // About Section
                Section("About") {
                    SettingsRow(
                        icon: "info.circle",
                        title: "About Lernig",
                        subtitle: "Version 1.0.0"
                    ) {
                        // Show about page
                    }
                    
                    SettingsRow(
                        icon: "questionmark.circle",
                        title: "Help & Support",
                        subtitle: "Get help and contact support"
                    ) {
                        // Open help
                    }
                    
                    SettingsRow(
                        icon: "star",
                        title: "Rate App",
                        subtitle: "Rate us on the App Store"
                    ) {
                        // Open App Store rating
                    }
                }
                
                // Account Section
                Section("Account") {
                    Button(action: { showingLogoutAlert = true }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.orange)
                            Text("Sign Out")
                                .font(.custom("AppleMyungjo", size: 16))
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Button(action: { showingDeleteAccountAlert = true }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("Delete Account")
                                .font(.custom("AppleMyungjo", size: 16))
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
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

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.primary)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.custom("AppleMyungjo", size: 16))
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.custom("AppleMyungjo", size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.system(size: 12))
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
}
