//
//  ContentView.swift
//  WordScramble
//
//  Created by Mert Ali Hanbay on 27.07.2023.
//

import SwiftUI

struct ContentView: View {

    @State private var usedWords: Array<String> = [String]()
    @State private var rootWord: String = ""
    @State private var newWord: String = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var score = 0


    var body: some View {

        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord).textInputAutocapitalization(.never)
                }
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle.fill")
                            Text(word)
                        }
                    }
                }
            }.navigationBarTitleDisplayMode(.inline)
                .toolbar {
                ToolbarItem(placement: .principal) {

                    VStack {
                        Text(rootWord)
                            .font(.largeTitle.bold())
                            .accessibilityAddTraits(.isHeader).padding(.top)
                        Text("Score: \(score)")
                            .font(.body)

                    }
                }
                ToolbarItem (placement: .navigationBarTrailing) {
                    Button("Restart") {
                        startGame()
                    }
                }
            }
                .onSubmit (addNewWord)
                .onAppear(perform: startGame)
                .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) { }

            } message: {
                Text(errorMessage)
            }
        }
    }

    func showWordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }

    func isWordExist(_ word: String) -> Bool {
        let checker: UITextChecker = UITextChecker()
        let range: NSRange = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }

    func isIncludesRootLetters(_ word: String) -> Bool {
        var tempWord: String = rootWord
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }

    func isOriginal(_ word: String) -> Bool {
        !usedWords.contains(word)
    }

    func startGame() {
        if let wordListUrl = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let wordsAsString = try? String(contentsOf: wordListUrl) {
                score = 0
                usedWords = []
                let words = wordsAsString.components(separatedBy: "\n")
                rootWord = words.randomElement() ?? "silkworm"
                return
            }
        }

        fatalError("Could not load start.txt from bundle.")
    }

    func addNewWord() {
        let answer: String = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }

        guard isOriginal(answer) else {
            showWordError(title: "Word used already", message: "Be more original")
            return
        }

        guard isIncludesRootLetters(answer) else {
            showWordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }

        guard isWordExist(answer) else {
            showWordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }

        withAnimation {
            score += 1
            usedWords.insert(newWord, at: 0)
        }
        newWord = ""
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
