import Foundation

struct Statistic: Codable {
    var frequencies = [Int](repeating: 0, count: 6)
    var games = 0
    var streak = 0
    var maxStreak = 0
    
    var wins: Int {
        frequencies.reduce(0, +)
    }
    
    func saveStat() {
        NSUbiquitousKeyValueStore.stat = self
    }
    static func loadStat() -> Statistic {
        NSUbiquitousKeyValueStore.stat
    }
    
    mutating func update(win: Bool, index: Int? = nil) {
        games += 1
        streak = win ? streak + 1 : 0
        if win {
            frequencies[index!] += 1
            maxStreak = max(maxStreak, streak)
        }
        saveStat()
    }
}
