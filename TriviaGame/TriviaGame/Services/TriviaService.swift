//
//  TriviaService.swift
//  TriviaGame
//
//  Created by Nam Nguyen on 11/7/24.
//

import Foundation

enum TriviaError: Error {
    case invalidURL
    case networkError
    case decodingError
}

class TriviaService {
    static let baseURL = "https://opentdb.com"
    
    static func fetchCategories() async throws -> [TriviaCategory] {
        guard let url = URL(string: "\(baseURL)/api_category.php") else {
            throw TriviaError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(TriviaCategoryResponse.self, from: data)
        return response.trivia_categories
    }
    
    static func fetchQuestions(amount: Int = 10,
                             category: String? = nil,
                             difficulty: String? = nil,
                             type: String? = nil) async throws -> [TriviaQuestion] {
        var urlComponents = URLComponents(string: "\(baseURL)/api.php")
        var queryItems = [URLQueryItem(name: "amount", value: String(amount))]
        
        if let category = category { queryItems.append(URLQueryItem(name: "category", value: category)) }
        if let difficulty = difficulty { queryItems.append(URLQueryItem(name: "difficulty", value: difficulty)) }
        if let type = type { queryItems.append(URLQueryItem(name: "type", value: type)) }
        
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else {
            throw TriviaError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(TriviaResponse.self, from: data)
        return response.results
    }
}
