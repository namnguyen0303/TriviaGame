//
//  QuestionView.swift
//  TriviaGame
//
//  Created by Nam Nguyen on 11/7/24.
//

import Foundation
import SwiftUI

struct QuestionView: View {
    let question: TriviaQuestion
    let selectedAnswer: String?
    let onAnswerSelected: (String) -> Void
    
    // Array of letters for answer options
    let letters = ["A", "B", "C", "D"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(question.question.removingHTMLEntities())
                .font(.headline)
                .padding(.bottom)
            
            ForEach(Array(question.all_answers.enumerated()), id: \.element) { index, answer in
                Button {
                    onAnswerSelected(answer)
                } label: {
                    HStack {
                        Text("\(letters[index]). \(answer.removingHTMLEntities())")
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedAnswer == answer {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(selectedAnswer == answer ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                    )
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

extension String {
    func removingHTMLEntities() -> String {
        return self.replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&#039;", with: "'")
            .replacingOccurrences(of: "&eacute;", with: "é")
    }
}
