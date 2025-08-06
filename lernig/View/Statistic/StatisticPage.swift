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

                        // GitHub Style Activity Grid
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Question Creation Activity")
                                    .font(.custom("SFProRounded-Medium", size: 20))
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Text("Last 12 weeks")
                                    .font(.custom("SFProRounded-Medium", size: 12))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)

                            HStack {
                                Spacer()
                                GitHubStyleActivityGrid(dailyActivities: stats.dailyActivities)
                                Spacer()
                            }
                        }

                        // Progress by Subject
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Progress by Subject")
                                .font(.custom("SFProRounded-Medium", size: 20))
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

                        // Recent Achievements (if any real achievements exist)
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
                    .font(.custom("SFProRounded-Medium", size: 24))
                    .fontWeight(.bold)
                
                Text(title)
                    .font(.custom("SFProRounded-Bold", size: 12))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        }
    }

    // MARK: - GitHub Style Activity Grid
    struct GitHubStyleActivityGrid: View {
        let dailyActivities: [DailyActivity]
        
        private var weeks: [[DailyActivity]] {
            let calendar = Calendar.current
            let today = Date()
            let startDate = calendar.date(byAdding: .day, value: -84, to: today) ?? today
            
            var weeks: [[DailyActivity]] = []
            var currentWeek: [DailyActivity] = []
            
            // Start from the beginning of the week containing startDate
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: startDate)?.start ?? startDate
            var currentDate = startOfWeek
            
            while currentDate <= today {
                let activity = dailyActivities.first { calendar.isDate($0.date, inSameDayAs: currentDate) }
                    ?? DailyActivity(date: currentDate, questionCount: 0)
                
                currentWeek.append(activity)
                
                // Check if week is complete (7 days)
                if currentWeek.count == 7 {
                    weeks.append(currentWeek)
                    currentWeek = []
                }
                
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            }
            
            // Add remaining days if any
            if !currentWeek.isEmpty {
                // Fill remaining days with empty activities for layout
                while currentWeek.count < 7 {
                    let nextDate = calendar.date(byAdding: .day, value: currentWeek.count, to: currentWeek.first?.date ?? Date()) ?? Date()
                    currentWeek.append(DailyActivity(date: nextDate, questionCount: 0, isPlaceholder: true))
                }
                weeks.append(currentWeek)
            }
            
            return weeks
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                // Month labels
                HStack {
                    ForEach(getMonthLabels(), id: \.offset) { month in
                        Text(month.name)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .frame(width: month.width, alignment: .leading)
                    }
                }
                
                HStack(alignment: .top, spacing: 3) {
                    // Day labels
                    VStack(spacing: 3) {
                        Text("")
                            .font(.caption2)
                            .frame(height: 12)
                        
                        ForEach(["M", "W", "F"], id: \.self) { day in
                            Text(day)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .frame(height: 12)
                        }
                    }
                    .frame(width: 15)
                    
                    // Activity grid
                    HStack(spacing: 3) {
                        ForEach(Array(weeks.enumerated()), id: \.offset) { weekIndex, week in
                            VStack(spacing: 3) {
                                ForEach(Array(week.enumerated()), id: \.offset) { dayIndex, activity in
                                    ActivityDaySquare(activity: activity)
                                }
                            }
                        }
                    }
                }
                
                // Legend
                HStack {
                    Text("Less")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 3) {
                        ForEach(0..<5) { level in
                            Rectangle()
                                .fill(getColorForLevel(level))
                                .frame(width: 12, height: 12)
                                .cornerRadius(2)
                        }
                    }
                    
                    Text("More")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        
        private func getMonthLabels() -> [(name: String, width: CGFloat, offset: Int)] {
            let calendar = Calendar.current
            let today = Date()
            let startDate = calendar.date(byAdding: .day, value: -84, to: today) ?? today
            
            var months: [(String, CGFloat, Int)] = []
            var currentMonth = -1
            var weekCount = 0
            
            for weekIndex in 0..<12 {
                let weekDate = calendar.date(byAdding: .weekOfYear, value: weekIndex, to: startDate) ?? startDate
                let month = calendar.component(.month, from: weekDate)
                
                if month != currentMonth {
                    let monthName = calendar.monthSymbols[month - 1].prefix(3).capitalized
                    let width: CGFloat = 45 // Approximate width for each month section
                    months.append((String(monthName), width, weekIndex))
                    currentMonth = month
                }
            }
            
            return months
        }
        
        private func getColorForLevel(_ level: Int) -> Color {
            switch level {
            case 0: return Color(.systemGray5)
            case 1: return Color.green.opacity(0.3)
            case 2: return Color.green.opacity(0.5)
            case 3: return Color.green.opacity(0.7)
            case 4: return Color.green
            default: return Color(.systemGray5)
            }
        }
    }

    struct ActivityDaySquare: View {
        let activity: DailyActivity
        
        private var intensityLevel: Int {
            if activity.isPlaceholder { return 0 }
            
            switch activity.questionCount {
            case 0: return 0
            case 1...2: return 1
            case 3...5: return 2
            case 6...10: return 3
            default: return 4
            }
        }
        
        private var color: Color {
            switch intensityLevel {
            case 0: return Color(.systemGray5)
            case 1: return Color.green.opacity(0.3)
            case 2: return Color.green.opacity(0.5)
            case 3: return Color.green.opacity(0.7)
            case 4: return Color.green
            default: return Color(.systemGray5)
            }
        }
        
        var body: some View {
            Rectangle()
                .fill(color)
                .frame(width: 12, height: 12)
                .cornerRadius(2)
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color(.systemGray4), lineWidth: activity.questionCount > 0 ? 0 : 0.5)
                )
        }
    }

    private func loadStatistics() {
        guard let userId = authViewModel.currentUser?.id else { return }

        isLoading = true
        Task {
            do {
                // Fetch lessons and their data
                let lessons = try await viewModel.repository.fetchLessons(for: userId)
                var totalTopics = 0
                var totalQuestions = 0
                var subjectProgress: [SubjectProgress] = []
                var allQuestions: [(date: Date, topicId: String)] = []

                for lesson in lessons {
                    let topics = try await viewModel.repository.fetchTopics(for: lesson.id)
                    totalTopics += topics.count

                    var lessonQuestions = 0
                    for topic in topics {
                        let questions = try await viewModel.repository.fetchQuestions(for: topic.id)
                        lessonQuestions += questions.count
                        
                        // Collect questions with their creation dates
                        for question in questions {
                            allQuestions.append((date: question.createdAt, topicId: topic.id))
                        }
                    }
                    totalQuestions += lessonQuestions

                    let progress = lessonQuestions > 0 ? Double(topics.count) / Double(lessonQuestions) * 100 : 0
                    subjectProgress.append(SubjectProgress(
                        name: lesson.name,
                        progress: min(progress, 100),
                        color: [.blue, .green, .orange, .purple, .pink].randomElement() ?? .blue
                    ))
                }

                // Generate daily activities from real data
                let dailyActivities = generateDailyActivities(from: allQuestions)
                let streak = calculateCurrentStreak(from: dailyActivities)
                let achievements = generateRealAchievements(
                    lessonsCount: lessons.count,
                    questionsCount: totalQuestions,
                    streak: streak
                )

                await MainActor.run {
                    stats.totalLessons = lessons.count
                    stats.totalTopics = totalTopics
                    stats.totalQuestions = totalQuestions
                    stats.subjectProgress = subjectProgress
                    stats.dailyActivities = dailyActivities
                    stats.studyStreak = streak
                    stats.recentAchievements = achievements
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

    private func generateDailyActivities(from questions: [(date: Date, topicId: String)]) -> [DailyActivity] {
        let calendar = Calendar.current
        let today = Date()
        let startDate = calendar.date(byAdding: .day, value: -84, to: today) ?? today
        
        // Group questions by date
        var questionsByDate: [Date: Int] = [:]
        
        for question in questions {
            let dayDate = calendar.startOfDay(for: question.date)
            questionsByDate[dayDate, default: 0] += 1
        }
        
        // Generate daily activities for the last 84 days
        var activities: [DailyActivity] = []
        var currentDate = startDate
        
        while currentDate <= today {
            let dayStart = calendar.startOfDay(for: currentDate)
            let questionCount = questionsByDate[dayStart] ?? 0
            
            activities.append(DailyActivity(
                date: currentDate,
                questionCount: questionCount
            ))
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return activities
    }

    private func calculateCurrentStreak(from activities: [DailyActivity]) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Sort activities by date (most recent first)
        let sortedActivities = activities
            .filter { $0.questionCount > 0 }
            .sorted { $0.date > $1.date }
        
        guard !sortedActivities.isEmpty else { return 0 }
        
        var streak = 0
        var currentDate = today
        
        // Check if there was activity today or yesterday (to handle late night studying)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today
        
        if let firstActivity = sortedActivities.first {
            let firstActivityDate = calendar.startOfDay(for: firstActivity.date)
            
            // If no activity today or yesterday, streak is 0
            if firstActivityDate < calendar.startOfDay(for: yesterday) {
                return 0
            }
            
            // Start counting from the most recent activity
            currentDate = firstActivityDate
        }
        
        // Count consecutive days with activity
        for activity in sortedActivities {
            let activityDate = calendar.startOfDay(for: activity.date)
            
            if calendar.isDate(activityDate, inSameDayAs: currentDate) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else if activityDate < currentDate {
                // There's a gap in the streak
                break
            }
        }
        
        return streak
    }

    private func generateRealAchievements(lessonsCount: Int, questionsCount: Int, streak: Int) -> [Achievement] {
        var achievements: [Achievement] = []
        let now = Date()
        
        // Achievement based on lessons created
        if lessonsCount >= 1 {
            achievements.append(Achievement(
                id: "first_lesson",
                title: "First Lesson Created",
                description: "Created your first lesson",
                date: now.addingTimeInterval(-Double(lessonsCount) * 86400)
            ))
        }
        
        if lessonsCount >= 5 {
            achievements.append(Achievement(
                id: "lesson_master",
                title: "Lesson Master",
                description: "Created 5 lessons",
                date: now.addingTimeInterval(-86400)
            ))
        }
        
        // Achievement based on questions created
        if questionsCount >= 10 {
            achievements.append(Achievement(
                id: "question_creator",
                title: "Question Creator",
                description: "Created 10 questions",
                date: now.addingTimeInterval(-172800)
            ))
        }
        
        if questionsCount >= 50 {
            achievements.append(Achievement(
                id: "quiz_master",
                title: "Quiz Master",
                description: "Created 50 questions",
                date: now.addingTimeInterval(-259200)
            ))
        }
        
        // Achievement based on streak
        if streak >= 3 {
            achievements.append(Achievement(
                id: "consistent_learner",
                title: "Consistent Learner",
                description: "\(streak) days in a row",
                date: now.addingTimeInterval(-345600)
            ))
        }
        
        if streak >= 7 {
            achievements.append(Achievement(
                id: "week_warrior",
                title: "Week Warrior",
                description: "7 day study streak",
                date: now.addingTimeInterval(-432000)
            ))
        }
        
        // Return only the most recent 3 achievements
        return Array(achievements.sorted { $0.date > $1.date }.prefix(3))
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
                .font(.custom("SFProRounded-Medium", size: 10))
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
                    .font(.custom("SFProRounded-Medium", size: 14))
                    .fontWeight(.medium)

                Text(achievement.description)
                    .font(.custom("SFProRounded-Medium", size: 12))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(formatTimeAgo(achievement.date))
                .font(.custom("SFProRounded-Medium", size: 10))
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
    var dailyActivities: [DailyActivity] = []
    var subjectProgress: [SubjectProgress] = []
    var recentAchievements: [Achievement] = []
}

struct DailyActivity {
    let date: Date
    let questionCount: Int
    let isPlaceholder: Bool
    
    init(date: Date, questionCount: Int, isPlaceholder: Bool = false) {
        self.date = date
        self.questionCount = questionCount
        self.isPlaceholder = isPlaceholder
    }
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
