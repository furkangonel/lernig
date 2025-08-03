//
//  TestQuestionData.swift
//  lernig
//
//  Created by Furkan Gönel on 31.07.2025.
//

import Foundation


struct TestQuestionData: Codable {
    let options: [String]
    let correctOptionIndex: Int
    
    var correctAnswer: String {
        guard correctOptionIndex >= 0 && correctOptionIndex < options.count else {
            return options.first ?? ""
        }
        return options[correctOptionIndex]
    }
    
    init(options: [String], correctOptionIndex: Int) {
        self.options = options
        self.correctOptionIndex = correctOptionIndex
    }
}
