import SwiftUI

struct TriviaQuestion: Codable {
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]

    var allAnswers: [String] {
        (incorrect_answers + [correct_answer]).shuffled()
    }
}

struct TriviaResponse: Codable {
    let results: [TriviaQuestion]
}

struct ContentView: View {
    @State private var questions: [TriviaQuestion] = []
    @State private var currentIndex = 0
    @State private var score = 0
    @State private var isFinished = false
    @State private var isLoading = false

    func fetchQuestions() async {
        isLoading = true
        let url = URL(string: "https://opentdb.com/api.php?amount=10&type=multiple")!
        let (data, _) = try! await URLSession.shared.data(from: url)
        let decoded = try! JSONDecoder().decode(TriviaResponse.self, from: data)
        questions = decoded.results
        isLoading = false
    }

    func answerTapped(_ answer: String) {
        if answer == questions[currentIndex].correct_answer {
            score += 1
        }
        if currentIndex + 1 < questions.count {
            currentIndex += 1
        } else {
            isFinished = true
        }
    }

    var body: some View {
        if isLoading {
            ProgressView("Loading questions...")
        } else if questions.isEmpty {
            VStack(spacing: 20) {
                Text("Pop Quiz 🧠")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Button("Start Quiz") {
                    Task { await fetchQuestions() }
                }
                .padding()
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
}

#Preview {
    ContentView()
}
