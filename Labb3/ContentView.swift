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

    var body: some View {
        Text("Pop Quiz")
            .font(.largeTitle)
    }
}

#Preview {
    ContentView()
}
