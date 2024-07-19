import SwiftUI

class GameDataModel: ObservableObject {
    @Published var guesses: [Guess] = []
    @Published var incorrectAttempts = [Int](repeating: 0, count: 6)
    @Published var msgText: String?
    @Published var showStats = false
    @AppStorage("hardMode") var hardMode = false
    
    var keyColors = [String : Color]()
    var matchedLetters = [String]()
    var misplacedLetters = [String]()
    var correctlyPlacedLetters = [String]()
    var selectedWord = ""
    var currentWord = ""
    var tryIndex = 0
    var inPlay = false
    var gameOver = false
    var currentStat: Statistic
    
    var gameStarted: Bool {
        !currentWord.isEmpty || tryIndex > 0
    }
    
    var disabledKeys: Bool {
        !inPlay || currentWord.count == 5
    }
    
    init() {
        currentStat = Statistic.loadStat()
        newGame()
    }
    
    func newGame() {
        populateDefaults()
        selectedWord = selectWord()
        selectedWord = "ASTER"
        correctlyPlacedLetters = [String](repeating: "-", count: 5)
        currentWord = ""
        inPlay = true
        tryIndex = 0
        gameOver = false
        showStats = false
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
            return "" // Or return a more informative error message
        }
    }
    
    func populateDefaults() {
        guesses = []
        for index in 0...5 {
            guesses.append(Guess(index: index))
        }
        //reset keyboard colors
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        for char in letters {
            keyColors[String(char)] = .unused
        }
        matchedLetters = []
        misplacedLetters = []
    }
    
    //gameplay
    func addToCurrentWord(_ letter: String) {
        currentWord += letter
        updateRow()
    }
    
    func enterWord() {
        if currentWord == selectedWord {
            gameOver = true
            setCurrentGuessColors()
            currentStat.update(win: true, index: tryIndex)
            showMsg(with: "You Win")
            inPlay = false
        } else {
            if verifyWord(currentWord) {
                //hard mode
                if hardMode {
                    if let hardWord = hardCorrectCheck() {
                        showMsg(with: hardWord)
                        return
                    }
                    if let hardWord = hardMisplacedCheck() {
                        showMsg(with: hardWord)
                        return
                    }
                }
                setCurrentGuessColors()
                tryIndex += 1
                currentWord = ""
                if tryIndex == 6 {
                    currentStat.update(win: false)
                    gameOver = true
                    inPlay = false
                    showMsg(with: selectedWord)
                }
            } else {
                withAnimation {
                    self.incorrectAttempts[tryIndex] += 1
                }
                showMsg(with: "Not in Word List")
                incorrectAttempts[tryIndex] = 0
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
    //hard mode code
    func hardCorrectCheck() -> String? {
        let guessLetters = guesses[tryIndex].guessLetters
        for i in 0...4 {
            if correctlyPlacedLetters[i] != "-" {
                if guessLetters[i] != correctlyPlacedLetters[i] {
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .ordinal
                    return "\(formatter.string(for: i + 1)!) Letter must be `\(correctlyPlacedLetters[i])`."
                }
            }
        }
        return nil
    }
    
    func hardMisplacedCheck() -> String? {
        let guessLetters = guesses[tryIndex].guessLetters
        for letter in misplacedLetters {
            if !guessLetters.contains(letter) {
                return ("Must contain the letter `\(letter)`.")
            }
        }
        return nil
    }
    //end hard mode
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
                    showStats.toggle()
                }
            }
        }
    }
}
