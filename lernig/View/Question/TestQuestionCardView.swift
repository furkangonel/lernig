//
//  TestQuestionCardView.swift
//  lernig
//
//  Created by Furkan Gönel on 2.08.2025.
//

import SwiftUI


struct TestQuestionCardView: View {
    let question: Question
    @State private var showAnswer = false
    @State private var selectedOption: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "list.bullet")
                    .foregroundColor(.green)
                    .font(.system(size: 12))
                Text("Multiple Choice")
                    .font(.custom("AppleMyungjo", size: 10))
                    .foregroundColor(.green)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(4)
                Spacer()
            }
            
            Text(question.questionText)
                .font(.custom("AppleMyungjo", size: 16))
                .fontWeight(.medium)
            
            if let testData = question.testData {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(testData.options, id: \.self) { option in
                        HStack {
                            Button(action: {
                                selectedOption = option
                            }) {
                                HStack {
                                    Image(systemName: selectedOption == option ? "largecircle.fill.circle" : "circle")
                                        .foregroundColor(selectedOption == option ? .blue : .gray)
                                    
                                    Text(option)
                                        .font(.custom("AppleMyungjo", size: 14))
                                        .foregroundColor(.primary)
                                        .multilineTextAlignment(.leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .lineLimit(nil)
                                        .layoutPriority(1)
                                    
                                    Spacer()
                                    
                                    if showAnswer {
                                        if option == testData.correctAnswer {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        } else if option == selectedOption && option != testData.correctAnswer {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(
                            showAnswer && option == testData.correctAnswer ? Color.green.opacity(0.1) :
                                showAnswer && option == selectedOption && option != testData.correctAnswer ? Color.red.opacity(0.1) :
                                selectedOption == option ? Color.blue.opacity(0.1) : Color.clear
                        )
                        .cornerRadius(8)
                    }
                }
                
                if showAnswer {
                    Text("Explanation: \(question.answerText)")
                        .font(.custom("AppleMyungjo", size: 12))
                        .foregroundColor(.secondary)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .transition(.opacity.combined(with: .slide))
                }
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
