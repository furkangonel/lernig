//
//  GeminiService.swift
//  lernig
//
//  Created by Furkan Gönel on 30.07.2025.
//

import Foundation
import FirebaseAI

class GeminiService {
    static let shared = GeminiService()
    
    private let ai: FirebaseAI
    private let model: GenerativeModel
    
    private init() {
        // Initialize the Gemini Developer API backend service
        self.ai = FirebaseAI.firebaseAI(backend: .googleAI())
        
        // Create a GenerativeModel instance with gemini-2.5-flash
        self.model = ai.generativeModel(modelName: "gemini-2.5-flash")
    }
    
    // MARK: - Text Generation
    func generateText(prompt: String) async throws -> String {
        let response = try await model.generateContent(prompt)
        guard let text = response.text, !text.isEmpty else {
            throw GeminiServiceError.noTextGenerated
        }
        return text
    }
    
    // MARK: - Content Generation for Learning
    func generateLearningContent(educationLevel: EducationLevel, lesson: String, topic: String, userPrompt: String) async throws -> String {
        let enhancedPrompt = """
        Ders: \(lesson)
        Konu: \(topic)
        Eğitim Seviyesi: \(educationLevel.rawValue.capitalized)
        Kullanıcı İsteği: \(userPrompt)
        
        Bu ders ve konu hakkında eğitici ve kapsamlı bir içerik oluştur. İçerik şunları içersin:
        
        1. Konuya giriş ve temel tanımlar
        2. Detaylar ve ileri seviye konuların tamamı
        3. Önemli kavramlar ve açıklamalar
        4. Pratik örnekler
        5. Özet ve sonuç
        
        İçerik Türkçe olsun ve öğrenci seviyesine uygun olsun.
        """
        
        return try await generateText(prompt: enhancedPrompt)
    }
    
    // MARK: - Question Generation
    func generateQuestions(lesson: String, topic: Topic, userPrompt: String, count: Int, educationLevel: EducationLevel, questionTypes: [QuestionType]) async throws -> [(question: String, answer: String, type: QuestionType, testData: TestQuestionData?)] {
        
        var allResults: [(question: String, answer: String, type: QuestionType, testData: TestQuestionData?)] = []
        
        for questionType in questionTypes {
            let typeCount = count / questionTypes.count + (questionTypes.firstIndex(of: questionType)! < count % questionTypes.count ? 1 : 0)
            
            let enhancedPrompt: String
            
            switch questionType {
            case .classic:
                enhancedPrompt = """
                Ders: \(lesson)
                Konu: \(topic.name)
                Eğitim Seviyesi: \(educationLevel.rawValue.capitalized)
                İstek: \(userPrompt)
                
                Bu ders ve konu hakkında \(typeCount) adet KLASİK soru-cevap çifti oluştur.
                Bu sorular konunun direkt kendisi ile ilgili olsun (yani Nasıl öğrenilir?, Hangi yol izlenmelidir? gibi sorular olmasın).
                Eğer ders sayısal içerikli ise işlem gerektiren sayısal sorulara da yer ver. 
                Çözümleri de öğrencinin anlayabileceği gibi işlem ve formul içersin.
                Eğer tamamen sözel bir ders ve konu ise direkt sözel sorular oluşturabilirsin.
                Eğitim seviyesine uygun olarak hazırla.
                
                Format:
                Soru 1: [Açık ve net soru]
                Cevap 1: [Detaylı cevap]
                
                Soru 2: [Açık ve net soru]
                Cevap 2: [Detaylı cevap]
                
                Sorular farklı zorluk seviyelerinde olsun ve konuyu iyi kavramayı test etsin.
                Türkçe yazın.
                """
                
            case .test:
                enhancedPrompt = """
                Ders: \(lesson)
                Konu: \(topic.name)
                Eğitim Seviyesi: \(educationLevel.rawValue.capitalized)
                İstek: \(userPrompt)
                
                Bu ders ve konu hakkında \(typeCount) adet ÇOK SEÇENEKLİ TEST sorusu oluştur.
                “Konuya doğrudan ilgili, ‘nasıl öğrenilir’ gibi sorular olmadan sorular oluştur.
                Eğer konu sayısalsa, hem işlem gerektiren sayısal hem de sözel sorular üret.
                Konu tamamen sözelse, sadece sözel sorular hazırla.
                Eğitim seviyesine uygun, farklı zorlukta, 4 seçenekli test soruları üret.
                Her soru için doğru cevabı ve nedenini açıklayan kısa bir açıklama ekle.
                Türkçe yaz.”
                """
            }
            
            print("Prompt sent: \(enhancedPrompt)")
            let response = try await generateText(prompt: enhancedPrompt)
            print("Response received: \(response)")
            //let parsed = parseQuestionsFromResponse(response, questionType: questionType, count: typeCount)
            let parsed = parseQuestions(from: response, type: questionType, topicId: topic.id)
            print("Parsed questions: \(parsed)")
            allResults.append(contentsOf: parsed)
        }
        
        print("ALL RESULTS: \(allResults)")
        return allResults
    }
    
    // MARK: - Content Generation
    func generateLearningContent(lesson: String, topic: String, userPrompt: String, educationLevel: EducationLevel) async throws -> String {
        let enhancedPrompt = """
        Ders: \(lesson)
        Konu: \(topic)
        Eğitim Seviyesi: \(educationLevel.rawValue.capitalized)
        Kullanıcı İsteği: \(userPrompt)
        
        Bu ders ve konu hakkında eğitici ve kapsamlı bir içerik oluştur.
        İçerik \(educationLevel.rawValue) seviyesine uygun olsun.
        
        İçerik şunları içersin:
        1. Konuya giriş ve temel tanımlar
        2. Detaylar ve ileri seviye konuların tamamı
        3. Önemli kavramlar ve açıklamalar
        4. Pratik örnekler
        5. Özet ve sonuç
        
        İçerik Türkçe olsun ve öğrenci seviyesine uygun olsun.
        """
        
        return try await generateText(prompt: enhancedPrompt)
    }
    
    
    
    func parseQuestions(from response: String, type: QuestionType, topicId: String) -> [(question: String, answer: String, type: QuestionType, testData: TestQuestionData?)] {
        var result: [(question: String, answer: String, type: QuestionType, testData: TestQuestionData?)] = []
        
        let lines = response.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        if type == .test {
            // Test soruları için parsing
            var currentQuestionText = ""
            var currentOptions: [String] = []
            var correctAnswerLetter = ""
            var explanation = ""
            
            func addQuestionIfValid() {
                guard !currentQuestionText.isEmpty,
                      currentOptions.count == 4,
                      !correctAnswerLetter.isEmpty else { return }
                
                let letters = ["A", "B", "C", "D"]
                let answerIndex = letters.firstIndex(of: correctAnswerLetter.uppercased()) ?? 0
                let testData = TestQuestionData(options: currentOptions, correctOptionIndex: answerIndex)
                let answer = explanation.isEmpty ? "Doğru cevap: \(correctAnswerLetter)" : explanation
                
                result.append((currentQuestionText, answer, type, testData))
            }
            
            for line in lines {
                // Soru baslangici
                if (line.contains("**Soru") || line.contains("Soru")) &&
                   (line.contains(":") || line.contains(".") || line.contains("**")) {
                    // Önceki soruyu ekle
                    addQuestionIfValid()
                    
                    // Yeni soru baslat
                    if line.contains("**Soru") {
                        // "**Soru 1**" formati
                        currentQuestionText = line.replacingOccurrences(of: "\\*+", with: "", options: .regularExpression)
                            .replacingOccurrences(of: "Soru\\s*\\d+", with: "", options: .regularExpression)
                            .trimmingCharacters(in: .whitespaces)
                    } else if let colonIndex = line.firstIndex(of: ":") {
                        currentQuestionText = String(line[line.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
                    } else if line.contains(".") {
                        // "1. Soru" formati için
                        let components = line.components(separatedBy: ".")
                        if components.count > 1 {
                            currentQuestionText = components.dropFirst().joined(separator: ".").trimmingCharacters(in: .whitespaces)
                            if currentQuestionText.hasPrefix("Soru") {
                                currentQuestionText = currentQuestionText.replacingOccurrences(of: "^Soru\\s*", with: "", options: .regularExpression).trimmingCharacters(in: .whitespaces)
                            }
                        }
                    }
                    currentOptions = []
                    correctAnswerLetter = ""
                    explanation = ""
                }
                // Secenekler A-B-C-D
                else if line.hasPrefix("A)") || line.hasPrefix("B)") || line.hasPrefix("C)") || line.hasPrefix("D)") {
                    let optionText = String(line.dropFirst(2)).trimmingCharacters(in: .whitespaces)
                    currentOptions.append(optionText)
                }
                // Dogru cevap
                else if line.contains("Doğru Cevap") {
                    // "**Doğru Cevap:** B" veya "Doğru Cevap: A" formatlarını destekle
                    let cleanedLine = line.replacingOccurrences(of: "\\*+", with: "", options: .regularExpression)
                    if let colonIndex = cleanedLine.firstIndex(of: ":") {
                        correctAnswerLetter = String(cleanedLine[cleanedLine.index(after: colonIndex)...])
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                }
                // Aciklama
                else if line.contains("Açıklama") {
                    let cleanedLine = line.replacingOccurrences(of: "\\*+", with: "", options: .regularExpression)
                    if let colonIndex = cleanedLine.firstIndex(of: ":") {
                        explanation = String(cleanedLine[cleanedLine.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
                    }
                }
                // Eger acıklama basladıysa ve yeni bir bölüm degil ise, aciklamayi ekle
                else if !explanation.isEmpty && !line.contains("**Soru") && !line.contains("Soru") &&
                        !line.contains("Doğru Cevap") && !line.hasPrefix("A)") && !line.hasPrefix("B)") &&
                        !line.hasPrefix("C)") && !line.hasPrefix("D)") && !line.contains("---") {
                    explanation += " " + line
                }
                // Eger currentQuestionText bos degil ise ve henuz secenekler baslamamis ise, soruya ekle
                else if !currentQuestionText.isEmpty && currentOptions.isEmpty &&
                        !line.contains("A)") && !line.contains("Doğru Cevap") &&
                        !line.contains("Açıklama") && !line.contains("**Soru") &&
                        !line.contains("Soru") && !line.contains("---") {
                    currentQuestionText += " " + line
                }
            }
            
            // Son soruyu ekle
            addQuestionIfValid()
            
        } else if type == .classic {
            // Klasik sorular için parsing
            var currentQuestionText = ""
            var currentAnswer = ""
            var isReadingAnswer = false
            
            func addQuestionIfValid() {
                guard !currentQuestionText.isEmpty, !currentAnswer.isEmpty else { return }
                
                result.append((
                    question: currentQuestionText,
                    answer: currentAnswer,
                    type: type,
                    testData: nil
                ))
            }
            
            for line in lines {
                // Soru başlangıcı
                if line.contains("Soru") && (line.contains(":") || line.contains(".")) {
                    // Önceki soruyu ekle
                    addQuestionIfValid()
                    
                    // Yeni soru başlat
                    isReadingAnswer = false
                    if let colonIndex = line.firstIndex(of: ":") {
                        currentQuestionText = String(line[line.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
                    } else if line.contains(".") {
                        let components = line.components(separatedBy: ".")
                        if components.count > 1 {
                            currentQuestionText = components.dropFirst().joined(separator: ".").trimmingCharacters(in: .whitespaces)
                            if currentQuestionText.hasPrefix("Soru") {
                                currentQuestionText = currentQuestionText.replacingOccurrences(of: "^Soru\\s*", with: "", options: .regularExpression).trimmingCharacters(in: .whitespaces)
                            }
                        }
                    }
                    currentAnswer = ""
                }
                // Cevap başlangıcı
                else if line.contains("Cevap") && (line.contains(":") || line.contains(".")) {
                    isReadingAnswer = true
                    if let colonIndex = line.firstIndex(of: ":") {
                        currentAnswer = String(line[line.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
                    } else if line.contains(".") {
                        let components = line.components(separatedBy: ".")
                        if components.count > 1 {
                            currentAnswer = components.dropFirst().joined(separator: ".").trimmingCharacters(in: .whitespaces)
                            if currentAnswer.hasPrefix("Cevap") {
                                currentAnswer = currentAnswer.replacingOccurrences(of: "^Cevap\\s*", with: "", options: .regularExpression).trimmingCharacters(in: .whitespaces)
                            }
                        }
                    }
                }
                // Eğer cevap okunuyorsa ve yeni bir soru/cevap başlığı değilse
                else if isReadingAnswer && !line.contains("Soru") && !line.contains("Cevap") && !line.contains("---") {
                    currentAnswer += " " + line
                }
                // Eğer soru okunuyorsa ve henüz cevap başlamamışsa
                else if !isReadingAnswer && !currentQuestionText.isEmpty && !line.contains("Cevap") && !line.contains("Soru") && !line.contains("---") {
                    currentQuestionText += " " + line
                }
            }
            
            // Son soruyu ekle
            addQuestionIfValid()
        }
        
        return result
    }
    
    
    

    // MARK: - Response Parsing (Updated for both types)
    private func parseQuestionsFromResponse(_ response: String, questionType: QuestionType, count: Int) -> [(question: String, answer: String, type: QuestionType, testData: TestQuestionData?)] {
        let lines = response.components(separatedBy: .newlines)
        switch questionType {
        case .classic:
            return parseClassicQuestions(lines: lines, count: count)
        case .test:
            return parseTestQuestions(lines: lines, count: count)
        }
    }

    private func parseClassicQuestions(lines: [String], count: Int) -> [(question: String, answer: String, type: QuestionType, testData: TestQuestionData?)] {
        var results: [(String, String, QuestionType, TestQuestionData?)] = []
        var currentQuestion = ""
        var currentAnswer = ""
        
        let soruRegex = try! NSRegularExpression(pattern: #"^Soru \d+:"#, options: [])
        let cevapRegex = try! NSRegularExpression(pattern: #"^Cevap \d+:"#, options: [])
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if soruRegex.firstMatch(in: trimmed, options: [], range: NSRange(location: 0, length: trimmed.utf16.count)) != nil {
                currentQuestion = trimmed.replacingOccurrences(of: #"^Soru \d+:\s*"#, with: "", options: .regularExpression)
            } else if cevapRegex.firstMatch(in: trimmed, options: [], range: NSRange(location: 0, length: trimmed.utf16.count)) != nil {
                currentAnswer = trimmed.replacingOccurrences(of: #"^Cevap \d+:\s*"#, with: "", options: .regularExpression)
            } else if !currentQuestion.isEmpty && currentAnswer.isEmpty && !trimmed.isEmpty {
                currentAnswer = trimmed
            } else if !currentAnswer.isEmpty && !trimmed.starts(with: "Soru") && !trimmed.isEmpty {
                currentAnswer += " \(trimmed)"
            }

            // Ekleme zamanı geldi mi?
            if !currentQuestion.isEmpty && !currentAnswer.isEmpty {
                results.append((currentQuestion, currentAnswer, .classic, nil))
                currentQuestion = ""
                currentAnswer = ""
                
                if results.count >= count { break }
            }
        }
        
        return Array(results.prefix(count))
    }

    private func parseTestQuestions(lines: [String], count: Int) -> [(question: String, answer: String, type: QuestionType, testData: TestQuestionData?)] {
        var results: [(String, String, QuestionType, TestQuestionData?)] = []
        
        var currentQuestion = ""
        var currentOptions: [String] = []
        var correctAnswerLetter = ""
        var explanation = ""
        
        let soruRegex = try! NSRegularExpression(pattern: #"^Soru \d+:"#, options: [])
        let optionRegex = try! NSRegularExpression(pattern: #"^[A-D]\)"#, options: [])
        let correctRegex = try! NSRegularExpression(pattern: #"^Doğru Cevap:\s*[A-D]"#, options: [])
        let explanationRegex = try! NSRegularExpression(pattern: #"^Açıklama:"#, options: [])
        
        func addQuestionIfValid() {
            guard !currentQuestion.isEmpty, currentOptions.count == 4, !correctAnswerLetter.isEmpty else { return }
            
            let optionIndex = ["A": 0, "B": 1, "C": 2, "D": 3][correctAnswerLetter] ?? 0
            let testData = TestQuestionData(options: currentOptions, correctOptionIndex: optionIndex)
            let answer = explanation.isEmpty ? "Doğru cevap: \(correctAnswerLetter)" : explanation
            
            results.append((currentQuestion, answer, .test, testData))
        }
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if soruRegex.firstMatch(in: trimmed, options: [], range: NSRange(location: 0, length: trimmed.utf16.count)) != nil {
                addQuestionIfValid()
                currentQuestion = trimmed.replacingOccurrences(of: #"^Soru \d+:\s*"#, with: "", options: .regularExpression)
                currentOptions = []
                correctAnswerLetter = ""
                explanation = ""
            } else if optionRegex.firstMatch(in: trimmed, options: [], range: NSRange(location: 0, length: trimmed.utf16.count)) != nil {
                let option = trimmed.replacingOccurrences(of: #"^[A-D]\)\s*"#, with: "", options: .regularExpression)
                currentOptions.append(option)
            } else if correctRegex.firstMatch(in: trimmed, options: [], range: NSRange(location: 0, length: trimmed.utf16.count)) != nil {
                correctAnswerLetter = trimmed.replacingOccurrences(of: #"^Doğru Cevap:\s*"#, with: "", options: .regularExpression)
            } else if explanationRegex.firstMatch(in: trimmed, options: [], range: NSRange(location: 0, length: trimmed.utf16.count)) != nil {
                explanation = trimmed.replacingOccurrences(of: #"^Açıklama:\s*"#, with: "", options: .regularExpression)
            }
        }
        
        addQuestionIfValid()
        
        return Array(results.prefix(count))
    }
}

// MARK: - Error Types
enum GeminiServiceError: Error, LocalizedError {
    case noTextGenerated
    case parsingFailed
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .noTextGenerated:
            return "AI'dan metin üretilemedi."
        case .parsingFailed:
            return "AI yanıtı işlenemedi."
        case .networkError(let message):
            return "Bağlantı hatası: \(message)"
        }
    }
}
