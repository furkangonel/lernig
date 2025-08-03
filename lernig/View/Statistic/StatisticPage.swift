//
//  StatisticView.swift
//  lernig
//
//  Created by Furkan Gönel on 30.07.2025.
//


import SwiftUI
import Charts

struct StatisticPage: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = LessonViewModel(currentUserId: "")
    @State private var stats = StatisticsData()
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if isLoading {
                        ProgressView("Loading statistics...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        // Overview Cards
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            StatCard(
                                title: "Total Lessons",
                                value: "\(stats.totalLessons)",
                                icon: "book.closed",
                                color: .blue
                            )
                            
                            StatCard(
                                title: "Total Topics",
                                value: "\(stats.totalTopics)",
                                icon: "list.bullet",
                                color: .green
                            )
                            
                            StatCard(
                                title: "Total Questions",
                                value: "\(stats.totalQuestions)",
                                icon: "questionmark.circle",
                                color: .orange
                            )
                            
                            StatCard(
                                title: "Study Streak",
                                value: "\(stats.studyStreak) days",
                                icon: "flame",
                                color: .red
                            )
                        }
                        .padding(.horizontal)
                        
                        // Weekly Activity Chart
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Weekly Activity")
                                .font(.custom("AppleMyungjo", size: 20))
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            Chart(stats.weeklyActivity, id: \.day) { item in
                                BarMark(
                                    x: .value("Day", item.day),
                                    y: .value("Activities", item.count)
                                )
                                .foregroundStyle(Color.blue.gradient)
                            }
                            .frame(height: 200)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                            .padding(.horizontal)
                        }
                        
                        // Progress by Subject
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Progress by Subject")
                                .font(.custom("AppleMyungjo", size: 20))
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                ForEach(stats.subjectProgress, id: \.name) { subject in
                                    SubjectProgressRow(subject: subject)
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                            .padding(.horizontal)
                        }
                        
                        // Recent Achievements
                        if !stats.recentAchievements.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Recent Achievements")
                                    .font(.custom("AppleMyungjo", size: 20))
                                    .fontWeight(.semibold)
                                    .padding(.horizontal)
                                
                                VStack(spacing: 8) {
                                    ForEach(stats.recentAchievements, id: \.id) { achievement in
                                        AchievementRow(achievement: achievement)
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
            .navigationTitle("Statistics")
            .refreshable {
                loadStatistics()
            }
            .onAppear {
                if let userId = authViewModel.currentUser?.id {
                    viewModel.currentUserId = userId
                    loadStatistics()
                }
            }
        }
    }
    
    private func loadStatistics() {
        guard let userId = authViewModel.currentUser?.id else { return }
        
        isLoading = true
        Task {
            do {
                let lessons = try await viewModel.repository.fetchLessons(for: userId)
                var totalTopics = 0
                var totalQuestions = 0
                var subjectProgress: [SubjectProgress] = []
                
                for lesson in lessons {
                    let topics = try await viewModel.repository.fetchTopics(for: lesson.id)
                    totalTopics += topics.count
                    
                    var lessonQuestions = 0
                    for topic in topics {
                        let questions = try await viewModel.repository.fetchQuestions(for: topic.id)
                        lessonQuestions += questions.count
                    }
                    totalQuestions += lessonQuestions
                    
                    // Subject progress
                    let progress = lessonQuestions > 0 ? Double(topics.count) / Double(lessonQuestions) * 100 : 0
                    subjectProgress.append(SubjectProgress(
                        name: lesson.name,
                        progress: min(progress, 100),
                        color: [.blue, .green, .orange, .purple, .pink].randomElement() ?? .blue
                    ))
                }
                
                await MainActor.run {
                    stats.totalLessons = lessons.count
                    stats.totalTopics = totalTopics
                    stats.totalQuestions = totalQuestions
                    stats.subjectProgress = subjectProgress
                    stats.weeklyActivity = generateMockWeeklyData()
                    stats.recentAchievements = generateMockAchievements()
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
                print("Error loading statistics: \(error)")
            }
        }
    }
    
    private func generateMockWeeklyData() -> [WeeklyActivity] {
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        return days.map { day in
            WeeklyActivity(day: day, count: Int.random(in: 0...10))
        }
    }
    
    private func generateMockAchievements() -> [Achievement] {
        return [
            Achievement(id: "1", title: "First Lesson Created", description: "Created your first lesson", date: Date()),
            Achievement(id: "2", title: "Quiz Master", description: "Completed 10 quizzes", date: Date().addingTimeInterval(-86400)),
            Achievement(id: "3", title: "Study Streak", description: "5 days in a row", date: Date().addingTimeInterval(-172800))
        ]
    }
}

struct SubjectProgressRow: View {
    let subject: SubjectProgress
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(subject.name)
                    .font(.custom("AppleMyungjo", size: 16))
                    .fontWeight(.medium)
                
                Text("\(Int(subject.progress))% Complete")
                    .font(.custom("AppleMyungjo", size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            CircularProgressView(progress: subject.progress / 100, color: subject.color)
                .frame(width: 40, height: 40)
        }
        .padding(.vertical, 4)
    }
}

struct CircularProgressView: View {
    let progress: Double
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.3), lineWidth: 4)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
            
            Text("\(Int(progress * 100))%")
                .font(.custom("AppleMyungjo", size: 10))
                .fontWeight(.semibold)
        }
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(.yellow)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.title)
                    .font(.custom("AppleMyungjo", size: 14))
                    .fontWeight(.medium)
                
                Text(achievement.description)
                    .font(.custom("AppleMyungjo", size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(formatTimeAgo(achievement.date))
                .font(.custom("AppleMyungjo", size: 10))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func formatTimeAgo(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Data Models
struct StatisticsData {
    var totalLessons = 0
    var totalTopics = 0
    var totalQuestions = 0
    var studyStreak = 0
    var weeklyActivity: [WeeklyActivity] = []
    var subjectProgress: [SubjectProgress] = []
    var recentAchievements: [Achievement] = []
}

struct WeeklyActivity {
    let day: String
    let count: Int
}

struct SubjectProgress {
    let name: String
    let progress: Double
    let color: Color
}

struct Achievement {
    let id: String
    let title: String
    let description: String
    let date: Date
}

#Preview {
    StatisticPage()
        .environmentObject(AuthViewModel())
}
