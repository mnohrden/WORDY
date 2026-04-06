import SwiftUI
import GameplayKit

class ChallengeManager: ObservableObject {
    @Published var isActive: Bool = false {
        didSet {
            UserDefaults.standard.set(isActive, forKey: "challengeActive")
            if !isActive {
                // When turning off challenge mode, clear stored seed/round
                currentSeed = nil
                currentRound = 0
                UserDefaults.standard.removeObject(forKey: "challengeSeed")
                UserDefaults.standard.set(0, forKey: "challengeRound")
            }
        }
    }
    
    @Published var currentSeed: String? = nil {
        didSet {
            if let seed = currentSeed {
                UserDefaults.standard.set(seed, forKey: "challengeSeed")
            }
        }
    }
    
    @Published var currentRound: Int = 0 {
        didSet {
            UserDefaults.standard.set(currentRound, forKey: "challengeRound")
        }
    }
    
    @Published var seedInput: String = ""
    
    // Cached shuffled word list for current seed
    private var shuffledWords: [String] = []
    
    init() {
        // Restore saved state
        self.isActive = UserDefaults.standard.bool(forKey: "challengeActive")
        self.currentSeed = UserDefaults.standard.string(forKey: "challengeSeed")
        self.currentRound = UserDefaults.standard.integer(forKey: "challengeRound")
        
        // Rebuild the shuffled list if we have a saved seed
        if let seed = currentSeed {
            shuffledWords = buildShuffledWords(from: seed)
        }
    }
    
    // MARK: - Seed Generation
    
    /// Generate a random 4-digit code
    func generateSeed() -> String {
        let code = String(format: "%04d", Int.random(in: 0...9999))
        return code
    }
    
    /// Start a new challenge session with a fresh seed
    func startNewChallenge() {
        let seed = generateSeed()
        currentSeed = seed
        currentRound = 0
        shuffledWords = buildShuffledWords(from: seed)
        isActive = true
    }
    
    /// Join a challenge by entering another player's seed
    func joinChallenge(seed: String) -> Bool {
        // Validate: must be exactly 4 digits
        let trimmed = seed.trimmingCharacters(in: .whitespaces)
        guard trimmed.count == 4,
              trimmed.allSatisfy({ $0.isNumber }) else {
            return false
        }
        currentSeed = trimmed
        currentRound = 0
        shuffledWords = buildShuffledWords(from: trimmed)
        isActive = true
        return true
    }
    
    /// Leave the current challenge
    func leaveChallenge() {
        isActive = false
    }
    
    // MARK: - Word Selection
    
    /// Get the word for the current round
    func wordForCurrentRound() -> String {
        guard !shuffledWords.isEmpty else { return "" }
        // Wrap around if somehow we exceed the list
        let index = currentRound % shuffledWords.count
        return shuffledWords[index].uppercased()
    }
    
    /// Advance to the next round (called when a game finishes)
    func advanceRound() {
        currentRound += 1
    }
    
    // MARK: - Deterministic Shuffle
    
    /// Build a deterministically shuffled word list using GKMersenneTwisterRandomSource
    /// seeded from the 4-digit code. Every device with the same seed
    /// gets the exact same word order.
    private func buildShuffledWords(from seed: String) -> [String] {
        guard let seedInt = UInt64(seed) else { return [] }
        
        // Load words from bundle
        guard let path = Bundle.main.path(forResource: "solution_words", ofType: "txt") else {
            print("Error: Could not find solution_words.txt")
            return []
        }
        
        do {
            let content = try String(contentsOfFile: path)
            // Handle both \n and \r separators
            var words = content.components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            
            // Sort first so every device starts from the same order
            words.sort()
            
            // Use GKMersenneTwisterRandomSource for deterministic shuffle
            let source = GKMersenneTwisterRandomSource(seed: seedInt)
            let shuffled = source.arrayByShufflingObjects(in: words) as! [String]
            
            return shuffled
        } catch {
            print("Error reading solution_words.txt: \(error)")
            return []
        }
    }
}