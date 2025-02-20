//
//  TriviaOptionsView.swift
//  TriviaGame
//
//  Created by Nam Nguyen on 11/7/24.
//

import Foundation
import SwiftUI

struct TriviaOptionsView: View {
    @State private var categories: [TriviaCategory] = []
    @State private var selectedCategoryId: Int?
    @State private var selectedDifficulty = "easy"
    @State private var questionType = "multiple"
    @State private var timerDuration = 60.0
    @State private var numberOfQuestions = "10"
    @State private var isLoading = false
    @State private var showGameView = false
    @State private var error: Error?
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading categories...")
                } else if let error = error {
                    VStack {
                        Text("Error loading categories")
                        Text(error.localizedDescription)
                        Button("Try Again") {
                            loadCategories()
                        }
                    }
                } else {
                    Form {
                        TextField("Number of Questions", text: $numberOfQuestions)
                            .keyboardType(.numberPad)
                        
                        Picker("Select Category", selection: $selectedCategoryId) {
                            Text("Any Category").tag(nil as Int?)
                            ForEach(categories) { category in
                                Text(category.name).tag(category.id as Int?)
                            }
                        }
                        
                        Picker("Difficulty", selection: $selectedDifficulty) {
                            Text("Easy").tag("easy")
                            Text("Medium").tag("medium")
                            Text("Hard").tag("hard")
                        }
                        
                        Picker("Question Type", selection: $questionType) {
                            Text("Multiple Choice").tag("multiple")
                            Text("True/False").tag("boolean")
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Timer Duration: \(Int(timerDuration)) seconds")
                            Slider(value: $timerDuration, in: 30...120, step: 10)
                        }
                    }
                    
                    Button(action: startGame) {
                        Text("Start Trivia")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding()
                    Text("Created by Nam Nguyen - z23539620")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom, 8)
                }
            }
            .navigationTitle("")  // Remove default navigation title
            .safeAreaInset(edge: .top) {
                Text("Trivia Game")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
            }
            .task {
                loadCategories()
            }
        }
        .fullScreenCover(isPresented: $showGameView) {
            NavigationView {  // Add this NavigationView wrapper
                if let categoryId = selectedCategoryId {
                    GameView(categoryId: String(categoryId),
                            difficulty: selectedDifficulty,
                            type: questionType,
                            timerDuration: Int(timerDuration),
                            numberOfQuestions: Int(numberOfQuestions) ?? 10)
                } else {
                    GameView(difficulty: selectedDifficulty,
                            type: questionType,
                            timerDuration: Int(timerDuration),
                            numberOfQuestions: Int(numberOfQuestions) ?? 10)
                }
            }
        }
    }
    
    private func loadCategories() {
        Task {
            isLoading = true
            do {
                categories = try await TriviaService.fetchCategories()
            } catch {
                self.error = error
            }
            isLoading = false
        }
    }
    
    private func startGame() {
        showGameView = true
    }
}
