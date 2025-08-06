//
//  AboutLernigView.swift
//  lernig
//
//  Created by Furkan Gönel on 4.08.2025.
//


import SwiftUI

struct AboutLernigView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // App Icon
                HStack {
                    Spacer()
                    Image("icon")
                        .resizable()
                        .scaledToFill()
                    Spacer()
                }

                // App Name & Version
                VStack(alignment: .center, spacing: 4) {
                    Text("Lernig")
                        .font(.custom("SFProRounded-Bold", size: 24))
                    Text("Version 1.0.0")
                        .font(.custom("SFProRounded-Regular", size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)

                Divider()

                // About Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("About")
                        .font(.custom("SFProRounded-Semibold", size: 18))

                    Text("Lernig is a smart and interactive learning assistant designed to help you organize lessons, generate AI-based study materials, and track your progress over time. Whether you're a student or a lifelong learner, Lernig is built to make studying more effective and enjoyable.")
                        .font(.custom("SFProRounded-Regular", size: 14))
                        .foregroundColor(.primary)
                }

                // Developer
                VStack(alignment: .leading, spacing: 8) {
                    Text("Developer")
                        .font(.custom("SFProRounded-Semibold", size: 18))

                    Text("Furkan Gönel\nfrkngnl000@gmail.com")
                        .font(.custom("SFProRounded-Regular", size: 14))
                        .foregroundColor(.primary)
                }

                // Acknowledgments
                VStack(alignment: .leading, spacing: 8) {
                    Text("Acknowledgments")
                        .font(.custom("SFProRounded-Semibold", size: 18))

                    Text("This app uses Google Gemini AI, Firebase Firestore, and SwiftUI technologies.")
                        .font(.custom("SFProRounded-Regular", size: 14))
                        .foregroundColor(.primary)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("About Lernig")
        .navigationBarTitleDisplayMode(.inline)
    }
}
