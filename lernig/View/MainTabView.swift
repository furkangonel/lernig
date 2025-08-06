//
//  MainTabView.swift
//  lernig
//
//  Created by Furkan Gönel on 30.07.2025.
//


import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var lessonViewModel: LessonViewModel
    @State private var selectedTab = 1 // second tab
    
    init() {
        self._lessonViewModel = StateObject(wrappedValue: LessonViewModel(currentUserId: ""))
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            StatisticPage()
                .tabItem {
                    Image("statistic_icon")
                    Text("Statistics")
                        .foregroundColor(Color("c_2"))
                }
                .tag(0)
                .toolbar(.visible, for: .tabBar)
                .toolbarBackground(Color("c_1"), for: .tabBar)
            
            LessonsPage(lessonViewModel: lessonViewModel)
                .tabItem {
                    Image("lesson_icon")
                    Text("Lessons")
                        .foregroundColor(Color("c_2"))
                }
                .tag(1)
                .toolbar(.visible, for: .tabBar)
                .toolbarBackground(Color("c_1"), for: .tabBar)

            
            ProfilePage()
                .tabItem {
                    Image("profile_icon")
                    Text("Profile")
                        .foregroundColor(Color("c_2"))
                }
                .tag(2)
                .toolbar(.visible, for: .tabBar)
                .toolbarBackground(Color("c_1"), for: .tabBar)
        }
        
        .onAppear {
            if let userId = authViewModel.currentUser?.id {
                lessonViewModel.currentUserId = userId
            }
        }
    }
}


#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
