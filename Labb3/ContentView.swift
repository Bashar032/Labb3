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
    @State private var timeRemaining = 15
    @State private var timer: Timer? = nil

    func fetchQuestions() async {
        isLoading = true
        let url = URL(string: "https://opentdb.com/api.php?amount=10&type=multiple")!
        let (data, _) = try! await URLSession.shared.data(from: url)
        let decoded = try! JSONDecoder().decode(TriviaResponse.self, from: data)
        questions = decoded.results
        isLoading = false
        startTimer()
    }

    func startTimer() {
        timeRemaining = 15
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                nextQuestion()
            }
        }
    }

    func answerTapped(_ answer: String) {
        if answer == questions[currentIndex].correct_answer {
            score += 1
        }
        nextQuestion()
    }

    func nextQuestion() {
        timer?.invalidate()
        if currentIndex + 1 < questions.count {
            currentIndex += 1
            startTimer()
        } else {
            isFinished = true
        }
    }

    var body: some View {
        if isLoading {
            ProgressView("Loading questions...")
        } else if isFinished {
            VStack(spacing: 20) {
                Text("Finished! 🎉")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Score: \(score) / \(questions.count)")
                    .font(.title2)
                    .foregroundColor(.purple)
                Text("Correct: \(score) ✅  Wrong: \(questions.count - score) ❌")
                    .foregroundColor(.gray)
                Button("Play Again") {
                    currentIndex = 0
                    score = 0
                    isFinished = false
                    Task { await fetchQuestions() }
                }
                .padding()
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
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
        } else {
            VStack(spacing: 20) {
                Text("Question \(currentIndex + 1) of \(questions.count)")
                    .foregroundColor(.gray)
                Text("⏱ \(timeRemaining)s")
                    .foregroundColor(timeRemaining <= 5 ? .red : .gray)
                ProgressView(value: Double(currentIndex + 1), total: Double(questions.count))
                    .tint(.purple)
                Text(questions[currentIndex].question)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding()
                ForEach(questions[currentIndex].allAnswers, id: \.self) { answer in
                    Button(action: { answerTapped(answer) }) {
                        Text(answer)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple.opacity(0.15))
                            .foregroundColor(.purple)
                            .cornerRadius(10)
                    }
                }
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
