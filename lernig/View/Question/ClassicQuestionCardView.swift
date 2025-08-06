//
//  ClassicQuestionCardView.swift
//  lernig
//
//  Created by Furkan Gönel on 2.08.2025.
//

import SwiftUI
import WKMarkdownView

struct ClassicQuestionCardView: View {
    let question: Question
    @State private var showAnswer = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "text.bubble")
                    .foregroundColor(.blue)
                    .font(.system(size: 12))
                Text("Classic")
                    .font(.custom("AppleMyungjo", size: 10))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)
                Spacer()
            }
            
            MarkdownView(question.questionText)
                .font(.custom("AppleMyungjo", size: 16))
                .clipped()
            
            if showAnswer {
                MarkdownView(question.answerText)
                    .font(.custom("AppleMyungjo", size: 16))
                    .foregroundColor(.secondary)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .transition(.opacity.combined(with: .slide))
                    .multilineTextAlignment(.leading)
                    .clipped()
            }
            
            Button(showAnswer ? "Hide Answer" : "Show Answer") {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showAnswer.toggle()
                }
            }
            .font(.custom("AppleMyungjo", size: 12))
            .foregroundColor(.blue)
        }
        .padding(.vertical, 8)
    }
}
