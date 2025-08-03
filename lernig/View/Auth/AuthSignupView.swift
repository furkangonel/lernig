//
//  AuthSignupView.swift
//  lernig
//
//  Created by Furkan Gönel on 30.07.2025.
//


import SwiftUI

struct AuthSignupView: View {
    @Binding var showSignUp: Bool
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    Image("icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .padding(.top, 20)
                }
                .padding(.bottom, 40)
                
                VStack(spacing: 16) {
                    CustomTextField("Ad & Soyad", text: $authViewModel.name)
                    CustomTextField("Username", text: $authViewModel.username)
                        .autocapitalization(.none)
                    CustomTextField("E-mail", text: $authViewModel.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    CustomSecureField("Password", text: $authViewModel.password)
                    
                    if let error = authViewModel.errorMessage {
                        Text(error).foregroundColor(.red).font(.footnote)
                    }
                    
                    Button {
                        authViewModel.register {
                            showSignUp = false
                        }
                    } label: {
                        if authViewModel.isLoading {
                            ProgressView().frame(maxWidth: .infinity)
                        } else {
                            Text("Sign Up")
                                .frame(maxWidth: .infinity)
                                .font(.custom("AppleMyungjo", size: 20))
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    
                    Button("Already have an account? Sign In") {
                        showSignUp = false
                    }
                    .padding(.top, 8)
                    .foregroundColor(Color("c_placeText"))
                    .font(
                        .custom("AppleMyungjo",
                                size: 12))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .gray.opacity(0.7), radius: 12, x: 0, y: 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 24)
            }
        }
    }
    
}

#Preview {
    AuthSignupView(showSignUp: .constant(true))
        .environmentObject(AuthViewModel())
}
