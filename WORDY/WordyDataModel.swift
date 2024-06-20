import SwiftUI

class GameDataModel: ObservableObject {
    //intialize stuff
    @Published var guesses: [Guess] = []
    @Published var incorrectAttempts = [Int](repeating: 0, count: 6)
    @Published var msgText: String?
    @Published var showStats = false
    
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
    
    // start new game
    init() {
        currentStat = Statistic.loadStat()
        newGame()
    }
    
    // setup
    func newGame() {
        populateDefaults()
        selectedWord = selectWord()
        correctlyPlacedLetters = [String](repeating: "-", count: 5)
        currentWord = ""
        inPlay = true
        tryIndex = 0
        gameOver = false
    }
    
    //get word from solution words .txt file
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
    
    //populate
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
            print("You Win")
            setCurrentGuessColors()
            currentStat.update(win: true, index: tryIndex)
            inPlay = false
        } else {
                if verifyWord(currentWord) {
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

    func setCurrentGuessColors() {
        let correctLetters = selectedWord.map { String($0) }                
        var frequency = [String : Int]()
        for letter in correctLetters {
            frequency[letter, default: 0] += 1
        }
        
        for index in 0..<correctLetters.count {
            let correctLetter = correctLetters[index]
            let guessLetter = guesses[tryIndex].guessLetters[index]
            if guessLetter == correctLetter {
                guesses[tryIndex].bgColors[index] = .correct
                if !matchedLetters.contains(guessLetter) {
                    matchedLetters.append(guessLetter)
                    keyColors[guessLetter] = .correct
                }
                if misplacedLetters.contains(guessLetter) {
                    if let index = misplacedLetters.firstIndex(where: {$0 == guessLetter}) {
                        misplacedLetters.remove(at: index)
                    }
                }
                correctlyPlacedLetters[index] = correctLetter
                frequency[guessLetter]! -= 1
            }
        }
        
        for index in 0...4 {
            let guessLetter = guesses[tryIndex].guessLetters[index]
            if correctLetters.contains(guessLetter)
                && guesses[tryIndex].bgColors[index] != .correct
                && frequency[guessLetter]! > 0 {
                guesses[tryIndex].bgColors[index] = .misplaced
                if !misplacedLetters.contains(guessLetter) && matchedLetters.contains(guessLetter) {
                    misplacedLetters.append(guessLetter)
                    keyColors[guessLetter] = .misplaced
                }
                frequency[guessLetter]! -= 1
            }
        }
        
        for index in 0...4 {
            let guessLetter = guesses[tryIndex].guessLetters[index]
            if keyColors[guessLetter] != .correct && keyColors[guessLetter] != .misplaced {
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
