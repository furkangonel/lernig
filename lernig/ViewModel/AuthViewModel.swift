//
//  AuthViewModel.swift
//  lernig
//
//  Created by Furkan Gönel on 30.07.2025.
//


import Foundation

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: User? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    @Published var name: String = ""
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var educationLevel: EducationLevel = .highschool
    
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository = FirebaseAuthRepository()) {
        self.authRepository = authRepository
    }
    
    func register(onSuccess: @escaping () -> Void) {
        Task {
            await registerUser(onSuccess: onSuccess)
        }
    }
    
    func login() {
        Task {
            await loginUser()
        }
    }
    
    func loadCurrentUser() {
        Task {
            await fetchCurrentUser()
        }
    }
    
    func logout() {
        do {
            try authRepository.logout()
            self.currentUser = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    
    // MARK: - Private async helpers
    private func registerUser(onSuccess: @escaping () -> Void) async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            let user = try await authRepository.register(
                name: name,
                username: username,
                email: email,
                password: password,
                educationLevel: educationLevel
            )
            self.currentUser = user
            await MainActor.run {
                onSuccess()
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
        self.isLoading = false
    }
    
    
    private func loginUser() async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            let user = try await authRepository.login(email: email, password: password)
            self.currentUser = user
        } catch {
            self.errorMessage = error.localizedDescription
        }
        self.isLoading = false
    }
    
    private func fetchCurrentUser() async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            let user = try await authRepository.getCurrentUser()
            self.currentUser = user
        } catch {
            self.errorMessage = error.localizedDescription
        }
        self.isLoading = false
    }
    
    
    func updateUserProfile(user: User) async throws {
           isLoading = true
           errorMessage = nil
           do {
               try await authRepository.updateUserProfile(user: user)
               self.currentUser = user
           } catch {
               self.errorMessage = error.localizedDescription
               throw error
           }
           isLoading = false
       }
    
    
}
