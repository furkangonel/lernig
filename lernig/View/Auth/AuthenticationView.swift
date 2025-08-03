//
//  AuthenticationView.swift
//  lernig
//
//  Created by Furkan Gönel on 30.07.2025.
//


import SwiftUI

struct AuthenticationView: View {
    @State private var showSignUp = false
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                if !showSignUp {
                    AuthSigninView(showSignUp: $showSignUp)
                        .transition(.slide)
                } else {
                    AuthSignupView(showSignUp: $showSignUp)
                        .transition(.slide)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: showSignUp)
        }
    }
}

