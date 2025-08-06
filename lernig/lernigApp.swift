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
                    CustomTabBarView()
                        .environmentObject(LessonViewModel(currentUserId: user.id))
                } else if authViewModel.isLoading {
                    ProgressView("Loading...")
                } else {
                    AuthenticationView()
                }
                
            }
            .tint(Color("c_0"))
            .environmentObject(authViewModel)
            .onAppear {
                authViewModel.loadCurrentUser()
            }
        }
    }
}
