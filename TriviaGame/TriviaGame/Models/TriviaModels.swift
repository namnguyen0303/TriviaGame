//
//  TriviaModels.swift
//  TriviaGame
//
//  Created by Nam Nguyen on 11/7/24.
//

import Foundation

struct TriviaCategory: Codable, Identifiable {
    let id: Int
    let name: String
}

struct TriviaCategoryResponse: Codable {
    let trivia_categories: [TriviaCategory]
}

struct TriviaQuestion: Codable, Identifiable {
    let id = UUID()
    let category: String
    let type: String
    let difficulty: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
    private let shuffledAnswers: [String] // Store shuffled answers
    
    // Now returns the stored shuffled answers instead of shuffling every time
    var all_answers: [String] {
        shuffledAnswers
    }
    
    enum CodingKeys: String, CodingKey {
        case category, type, difficulty, question, correct_answer, incorrect_answers
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        category = try container.decode(String.self, forKey: .category)
        type = try container.decode(String.self, forKey: .type)
        difficulty = try container.decode(String.self, forKey: .difficulty)
        question = try container.decode(String.self, forKey: .question)
        correct_answer = try container.decode(String.self, forKey: .correct_answer)
        incorrect_answers = try container.decode([String].self, forKey: .incorrect_answers)
        // Shuffle answers only once during initialization
        shuffledAnswers = (incorrect_answers + [correct_answer]).shuffled()
    }
}

struct TriviaResponse: Codable {
    let response_code: Int
    let results: [TriviaQuestion]
}
