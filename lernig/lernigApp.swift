//
//  lernigApp.swift
//  lernig
//
//  Created by Furkan Gönel on 29.07.2025.
//

import SwiftUI
import FirebaseCore

@main
struct lernigApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if let user = authViewModel.currentUser {
                    MainTabView()
                        .environmentObject(LessonViewModel(currentUserId: user.id))
                } else if authViewModel.isLoading {
                    ProgressView("Loading...")
                } else {
                    AuthenticationView()
                }
            }
            .environmentObject(authViewModel)
            .onAppear {
                authViewModel.loadCurrentUser()
            }
        }
    }
}
