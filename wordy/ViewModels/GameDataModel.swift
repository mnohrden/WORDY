import SwiftUI

class GameDataModel: ObservableObject {
    @Published var guesses: [Guess] = []
    @Published var incorrectAttempts = [Int](repeating: 0, count: 6)
    @Published var msgText: String?
    // 0 = Easy, 1 = Medium, 2 = Hard
    @AppStorage("difficulty") var difficulty = 0

    var keyColors = [String : Color]()
    var matchedLetters = [String]()
    var misplacedLetters = [String]()
    var correctlyPlacedLetters = [String]()
    var wrongLetters = Set<String>()
    var misplacedPositions = [String: Set<Int>]()
    var selectedWord = ""
    var currentWord = ""
    var tryIndex = 0
    var inPlay = false
    var gameOver = false
    @Published var showStats = false

    // Challenge mode reference (set by wordyApp on launch)
    var challengeManager: ChallengeManager?

    var gameStarted: Bool {
        !currentWord.isEmpty || tryIndex > 0
    }

    var disabledKeys: Bool {
        !inPlay || currentWord.count == 5
    }

    var canRestart: Bool {
        difficulty == 0 || gameOver || !gameStarted
    }

    init() {
        newGame()
    }

    func newGame() {
        populateDefaults()
        if let cm = challengeManager, cm.isActive {
            selectedWord = cm.wordForCurrentRound()
        } else {
            selectedWord = selectWord()
        }
        correctlyPlacedLetters = [String](repeating: "-", count: 5)
        wrongLetters = Set<String>()
        misplacedPositions = [String: Set<Int>]()
        currentWord = ""
        inPlay = true
        tryIndex = 0
        gameOver = false
    }

    func selectWord() -> String {
        guard let path = Bundle.main.path(forResource: "solution_words", ofType: "txt") else {
            print("Error: Could not find solution_words.txt")
            return ""
        }

        do {
            let content = try String(contentsOfFile: path)
            let allwords = Set(content.components(separatedBy: .newlines))
            if let randomWord = allwords.randomElement() {
                return randomWord.uppercased()
            } else {
                print("Error: solution_words.txt empty")
                return ""
            }
        } catch {
            print("Error: Could not read file: \(error)")
            return ""
        }
    }

    func populateDefaults() {
        guesses = []
        for index in 0...5 {
            guesses.append(Guess(index: index))
        }
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        for char in letters {
            keyColors[String(char)] = .unused
        }
        matchedLetters = []
        misplacedLetters = []
    }

    // MARK: - Gameplay

    func addToCurrentWord(_ letter: String) {
        currentWord += letter
        updateRow()
    }

    func enterWord() {
        if currentWord == selectedWord {
            gameOver = true
            setCurrentGuessColors()
            showMsg(with: "You Win")
            inPlay = false
            if let cm = challengeManager, cm.isActive {
                cm.advanceRound()
            }
        } else {
            if verifyWord(currentWord) {
                // Hard mode validation
                if difficulty == 2 {
                    if let msg = hardWrongLetterCheck() {
                        rejectGuess(msg)
                        return
                    }
                    if let msg = hardCorrectCheck() {
                        rejectGuess(msg)
                        return
                    }
                    if let msg = hardMisplacedCheck() {
                        rejectGuess(msg)
                        return
                    }
                    if let msg = hardMisplacedPositionCheck() {
                        rejectGuess(msg)
                        return
                    }
                }
                setCurrentGuessColors()
                tryIndex += 1
                currentWord = ""
                if tryIndex == 6 {
                    gameOver = true
                    inPlay = false
                    showMsg(with: selectedWord)
                    if let cm = challengeManager, cm.isActive {
                        cm.advanceRound()
                    }
                }
            } else {
                rejectGuess("Not in Word List")
            }
        }
    }

    func removeLetterFromCurrentWord() {
        currentWord.removeLast()
        updateRow()
    }

    func updateRow() {
        let guessWord = currentWord.padding(toLength: 5, withPad: " ", startingAt: 0)
        guesses[tryIndex].word = guessWord
    }

    func verifyWord(_ word: String) -> Bool {
        let lower_word = word.lowercased()
        guard let path = Bundle.main.path(forResource: "allowed_words", ofType: "txt") else {
            print("Error: Could not find allowed_words.txt")
            return false
        }
        do {
            let content = try String(contentsOfFile: path)
            let allowedWords = Set(content.components(separatedBy: .newlines))
            return allowedWords.contains(lower_word)
        } catch {
            print("Error: Could not read allowed_words.txt: \(error)")
            return false
        }
    }

    // MARK: - Hard Mode Checks

    private func rejectGuess(_ message: String) {
        withAnimation {
            self.incorrectAttempts[tryIndex] += 1
        }
        showMsg(with: message)
        incorrectAttempts[tryIndex] = 0
    }

    func hardWrongLetterCheck() -> String? {
        let guessLetters = guesses[tryIndex].guessLetters
        for letter in guessLetters {
            if wrongLetters.contains(letter) {
                return "Try again"
            }
        }
        return nil
    }

    func hardCorrectCheck() -> String? {
        let guessLetters = guesses[tryIndex].guessLetters
        for i in 0...4 {
            if correctlyPlacedLetters[i] != "-" {
                if guessLetters[i] != correctlyPlacedLetters[i] {
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .ordinal
                    return "\(formatter.string(for: i + 1)!) letter must be \(correctlyPlacedLetters[i])"
                }
            }
        }
        return nil
    }

    func hardMisplacedCheck() -> String? {
        let guessLetters = guesses[tryIndex].guessLetters
        for letter in misplacedLetters {
            if !guessLetters.contains(letter) {
                return "Must contain the letter \(letter)"
            }
        }
        return nil
    }

    func hardMisplacedPositionCheck() -> String? {
        let guessLetters = guesses[tryIndex].guessLetters
        for (index, letter) in guessLetters.enumerated() {
            if let bannedPositions = misplacedPositions[letter], bannedPositions.contains(index) {
                let formatter = NumberFormatter()
                formatter.numberStyle = .ordinal
                return "\(letter) can't be \(formatter.string(for: index + 1)!)"
            }
        }
        return nil
    }

    // MARK: - Color Assignment

    func setCurrentGuessColors() {
        let correctLetters = selectedWord.map { String($0) }
        var frequency = [String: Int]()
        for letter in correctLetters {
            frequency[letter, default: 0] += 1
        }

        // First pass: Mark correct letters
        for index in 0..<correctLetters.count {
            let correctLetter = correctLetters[index]
            let guessLetter = guesses[tryIndex].guessLetters[index]
            if guessLetter == correctLetter {
                guesses[tryIndex].bgColors[index] = .correct
                keyColors[guessLetter] = .correct
                frequency[guessLetter]! -= 1
            }
        }
        // Second pass: Mark misplaced and wrong letters
        for index in 0..<correctLetters.count {
            let guessLetter = guesses[tryIndex].guessLetters[index]
            if guesses[tryIndex].bgColors[index] != .correct {
                if frequency[guessLetter, default: 0] > 0 {
                    guesses[tryIndex].bgColors[index] = .misplaced_letter
                    if keyColors[guessLetter] != .correct {
                        keyColors[guessLetter] = .misplaced_letter
                    }
                    frequency[guessLetter]! -= 1
                } else {
                    guesses[tryIndex].bgColors[index] = .wrong
                    if keyColors[guessLetter] != .correct && keyColors[guessLetter] != .misplaced_letter {
                        keyColors[guessLetter] = .wrong
                    }
                }
            }
        }
        // Third pass: Ensure all guessed letters that aren't correct or misplaced are marked as wrong
        for guessLetter in guesses[tryIndex].guessLetters {
            if keyColors[guessLetter] == nil {
                keyColors[guessLetter] = .wrong
            }
        }

        // Update hard mode tracking
        if difficulty == 2 {
            for index in 0..<5 {
                let guessLetter = guesses[tryIndex].guessLetters[index]
                let color = guesses[tryIndex].bgColors[index]
                if color == .correct {
                    correctlyPlacedLetters[index] = guessLetter
                } else if color == .misplaced_letter {
                    if !misplacedLetters.contains(guessLetter) {
                        misplacedLetters.append(guessLetter)
                    }
                    misplacedPositions[guessLetter, default: Set()].insert(index)
                }
            }
            for (letter, color) in keyColors {
                if color == .wrong {
                    wrongLetters.insert(letter)
                }
            }
        }

        flipCards(for: tryIndex)
    }

    func flipCards(for row: Int) {
        for col in 0...4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(col) * 0.2) {
                self.guesses[row].cardFlipped[col].toggle()
            }
        }
    }

    func showMsg(with text: String?) {
        withAnimation {
            msgText = text
        }
        withAnimation(Animation.linear(duration: 0.2).delay(3)) {
            msgText = nil
            if gameOver {
                withAnimation(Animation.linear(duration: 0.2).delay(3)) {
                }
            }
        }
    }
}
