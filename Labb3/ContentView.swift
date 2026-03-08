import SwiftUI


struct TriviaQuestion: Codable {
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
}

struct TriviaResponse: Codable {
    let results: [TriviaQuestion]
}

struct ContentView: View {
    var body: some View {
        Text("Pop Quiz")
            .font(.largeTitle)
    }
}

#Preview {
    ContentView()
}
