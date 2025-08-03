//
//  AuthRepository.swift
//  lernig
//
//  Created by Furkan Gönel on 30.07.2025.
//


import Foundation
import FirebaseAuth
import FirebaseFirestore


protocol AuthRepository {
    func register(name: String, username: String, email: String, password: String, educationLevel: EducationLevel) async throws -> User
    func login(email: String, password: String) async throws -> User
    func getCurrentUser() async throws -> User
    func logout() throws
    
    func updateUserProfile(user: User) async throws
}



class FirebaseAuthRepository: AuthRepository {
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    
    //MARK: - register func
    func register(
        name: String,
        username: String,
        email: String,
        password: String,
        educationLevel: EducationLevel
    ) async throws -> User {
        
        let authResult = try await auth.createUser(withEmail: email, password: password)
        let userId = authResult.user.uid
        
        let user = User(
            id: userId,
            name: name,
            username: username,
            email: email,
            educationLevel: educationLevel
        )
        
        
        try await db.collection("users").document(userId).setData([
            "name": name,
            "username": username,
            "email": email,
            "educationLevel": educationLevel.rawValue
        ])
        
        return user
    }
    
    
    //MARK: - login func
    func login(email: String, password: String) async throws -> User {
        let authResult = try await auth.signIn(withEmail: email, password: password)
        let userId = authResult.user.uid
        
        let snapshot = try await db.collection("users").document(userId).getDocument()
        guard let data = snapshot.data(),
              let name = data["name"] as? String,
              let username = data["username"] as? String,
              let email = data["email"] as? String,
              let educationLevelRaw = data["educationLevel"] as? String,
              let educationLevel = EducationLevel(rawValue: educationLevelRaw)
        else {
            throw NSError(domain: "AuthRepository", code: 0, userInfo: [NSLocalizedDescriptionKey: "User data missing"])
        }
        return User(id: userId, name: name, username: username, email: email, educationLevel: educationLevel)
    }
    
    
    //MARK: - getCurrentUser func
    func getCurrentUser() async throws -> User {
        guard let currentUser = auth.currentUser else { throw NSError(domain: "AuthRepository", code: 0, userInfo: [NSLocalizedDescriptionKey: "No current user"])
        }
        
        let snapshot = try await db.collection("users").document(currentUser.uid).getDocument()
        guard let data = snapshot.data(),
              let name = data["name"] as? String,
              let username = data["username"] as? String, // ✅ Firestore’dan çek
              let email = data["email"] as? String,
              let educationLevelRaw = data["educationLevel"] as? String,
              let educationLevel = EducationLevel(rawValue: educationLevelRaw)
        else {
            throw NSError(domain: "AuthRepository", code: 0, userInfo: [NSLocalizedDescriptionKey: "User data missing"])
        }
        
        return User(id: currentUser.uid, name: name, username: username, email: email, educationLevel: educationLevel)
    }
    
    
    //MARK: - logout func
    func logout() throws {
        try auth.signOut()
    }
    
    
    // MARK: - update func
    func updateUserProfile(user: User) async throws {
        try await db.collection("users").document(user.id).setData([
            "name": user.name,
            "username": user.username,
            "email": user.email,
            "educationLevel": user.educationLevel.rawValue
        ], merge: true)
    }
    
    
    
}
