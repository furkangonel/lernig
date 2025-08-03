//
//  ProfilePage.swift
//  lernig
//
//  Created by Furkan Gönel on 30.07.2025.
//


import SwiftUI

struct ProfilePage: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var lessonViewModel = LessonViewModel(currentUserId: "")
    @State private var stats = ProfileStats()
    @State private var showingSettings = false
    @State private var showingEditProfile = false

    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // User Profile Header
                    if let user = authViewModel.currentUser {
                        VStack(spacing: 16) {
                            Circle()
                                .fill(Color("c_1"))
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Text(String(user.name.prefix(1)).uppercased())
                                        .font(.custom("AppleMyungjo", size: 36))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                )
                            
                            VStack(spacing: 4) {
                                Text(user.name)
                                    .font(.custom("AppleMyungjo", size: 24))
                                    .fontWeight(.bold)
                                
                                Text("@\(user.username)")
                                    .font(.custom("AppleMyungjo", size: 16))
                                    .foregroundColor(.secondary)
                                
                                Text(user.email)
                                    .font(.custom("AppleMyungjo", size: 14))
                                    .foregroundColor(.secondary)
                                
                                // Education Level Badge
                                Text(user.educationLevel.rawValue.capitalized)
                                    .font(.custom("AppleMyungjo", size: 12))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color("c_1").opacity(0.2))
                                    .foregroundColor(Color("c_1"))
                                    .cornerRadius(12)
                            }
                            Button("Edit Profile") {
                                showingEditProfile = true
                            }
                            .font(.custom("AppleMyungjo", size: 14))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color("c_1").opacity(0.1))
                            .foregroundColor(Color("c_1"))
                            .cornerRadius(12)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                        .padding(.horizontal)
                        
                        
                        // Quick Actions
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Quick Actions")
                                .font(.custom("AppleMyungjo", size: 20))
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                ActionButton(
                                    title: "Settings",
                                    subtitle: "Manage your account and preferences",
                                    icon: "gear",
                                    action: { showingSettings = true }
                                )
                                
                                ActionButton(
                                    title: "Export Data",
                                    subtitle: "Download your lessons and progress",
                                    icon: "square.and.arrow.up",
                                    action: { exportData() }
                                )
                                
                                ActionButton(
                                    title: "Share App",
                                    subtitle: "Invite friends to join Lernig",
                                    icon: "square.and.arrow.up.on.square",
                                    action: { shareApp() }
                                )
                            }
                            .padding(.horizontal)
                        }
                        
                        // Recent Activity
                        if !stats.recentActivities.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Recent Activity")
                                    .font(.custom("AppleMyungjo", size: 20))
                                    .fontWeight(.semibold)
                                    .padding(.horizontal)
                                
                                VStack(spacing: 8) {
                                    ForEach(stats.recentActivities, id: \.id) { activity in
                                        ActivityRow(activity: activity)
                                    }
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.bottom, 100)
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
        }
    }
    

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

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.custom("AppleMyungjo", size: 24))
                .fontWeight(.bold)
            
            Text(title)
                .font(.custom("AppleMyungjo", size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

struct ActionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            // Basic haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            action()
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color("c_1"))
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.custom("AppleMyungjo", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.custom("AppleMyungjo", size: 12))
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

struct ActivityRow: View {
    let activity: RecentActivity
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: activity.type.icon)
                .font(.system(size: 16))
                .foregroundColor(activity.type.color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.title)
                    .font(.custom("AppleMyungjo", size: 14))
                    .foregroundColor(.primary)
                
                Text(formatTimeAgo(activity.date))
                    .font(.custom("AppleMyungjo", size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private func formatTimeAgo(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Data Models
struct ProfileStats {
    var totalLessons = 0
    var totalTopics = 0
    var totalQuestions = 0
    var studyStreak = 0
    var recentActivities: [RecentActivity] = []
}

struct RecentActivity {
    let id: String
    let title: String
    let date: Date
    let type: ActivityType
}

enum ActivityType {
    case lessonCreated
    case topicAdded
    case questionAdded
    case contentGenerated
    
    var icon: String {
        switch self {
        case .lessonCreated: return "book.closed"
        case .topicAdded: return "list.bullet"
        case .questionAdded: return "questionmark.circle"
        case .contentGenerated: return "sparkles"
        }
    }
    
    var color: Color {
        switch self {
        case .lessonCreated: return .blue
        case .topicAdded: return .green
        case .questionAdded: return .orange
        case .contentGenerated: return .purple
        }
    }
}

#Preview {
    ProfilePage()
        .environmentObject(AuthViewModel())
}
