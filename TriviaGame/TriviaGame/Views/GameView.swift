//
//  GameView.swift
//  TriviaGame
//
//  Created by Nam Nguyen on 11/7/24.
//

import Foundation
import SwiftUI

struct GameView: View {
    let categoryId: String?
    let difficulty: String
    let type: String
    let timerDuration: Int
    let numberOfQuestions: Int
    
    @State private var questions: [TriviaQuestion] = []
    @State private var selectedAnswers: [UUID: String] = [:]
    @State private var timeRemaining: Int
    @State private var isLoading = false
    @State private var error: Error?
    @State private var showScore = false
    @State private var score = 0
    @State private var hasSubmitted = false
    @Environment(\.dismiss) private var dismiss
    
    init(categoryId: String? = nil,
         difficulty: String,
         type: String,
         timerDuration: Int,
         numberOfQuestions: Int) {
        self.categoryId = categoryId
        self.difficulty = difficulty
        self.type = type
        self.timerDuration = timerDuration
        self.numberOfQuestions = numberOfQuestions
        _timeRemaining = State(initialValue: timerDuration)
    }
    
    var body: some View {
        VStack {
            Text("Time remaining: \(timeRemaining)s")
                .font(.headline)
                .padding()
            
            if isLoading {
                ProgressView("Loading questions...")
            } else if let error = error {
                VStack {
                    Text("Error loading questions")
                    Text(error.localizedDescription)
                    Button("Try Again") {
                        loadQuestions()
                    }
                }
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(questions) { question in
                            VStack(alignment: .leading, spacing: 12) {
                                Text(question.question.removingHTMLEntities())
                                    .font(.headline)
                                    .padding(.bottom)
                                
                                ForEach(Array(question.all_answers.enumerated()), id: \.element) { index, answer in
                                    Button {
                                        if !hasSubmitted {
                                            selectedAnswers[question.id] = answer
                                        }
                                    } label: {
                                        HStack {
                                            Text("\(["A", "B", "C", "D"][index]). \(answer.removingHTMLEntities())")
                                                .foregroundColor(.primary)
                                            Spacer()
                                            if hasSubmitted {
                                                if answer == question.correct_answer {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(.green)
                                                } else if selectedAnswers[question.id] == answer {
                                                    Image(systemName: "x.circle.fill")
                                                        .foregroundColor(.red)
                                                }
                                            } else if selectedAnswers[question.id] == answer {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(getAnswerBackgroundColor(answer: answer, question: question))
                                        )
                                    }
                                    .disabled(hasSubmitted)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                        }
                    }
                    .padding()
                }
                
                Button(action: {
                    hasSubmitted = true
                    calculateScore()
                }) {
                    Text("Submit")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
                .disabled(hasSubmitted)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Exit")
                    }
                    .foregroundColor(.red)  // Make it more visible
                }
            }
        }
        .task {
            loadQuestions()
            startTimer()
        }
        .alert("Score", isPresented: $showScore) {
            Button("OK") {
                showScore = false
            }
        } message: {
            Text("Your score: \(score)/\(questions.count)")
        }
    }
    
    private func getAnswerBackgroundColor(answer: String, question: TriviaQuestion) -> Color {
        guard hasSubmitted else {
            return selectedAnswers[question.id] == answer ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1)
        }
        
        if answer == question.correct_answer {
            return Color.green.opacity(0.1)
        } else if selectedAnswers[question.id] == answer {
            return Color.red.opacity(0.1)
        }
        return Color.gray.opacity(0.1)
    }
    
    private func loadQuestions() {
        Task {
            isLoading = true
            do {
                questions = try await TriviaService.fetchQuestions(
                    amount: numberOfQuestions,
                    category: categoryId,
                    difficulty: difficulty,
                    type: type
                )
            } catch {
                self.error = error
            }
            isLoading = false
        }
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer.invalidate()
                if !hasSubmitted {
                    hasSubmitted = true
                    calculateScore()
                }
            }
        }
    }
    
    private func calculateScore() {
        score = 0
        for question in questions {
            if let selectedAnswer = selectedAnswers[question.id],
               selectedAnswer == question.correct_answer {
                score += 1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showScore = true
        }
    }
}
