import SwiftUI

extension Color {
    static var wrong: Color {
        Color(UIColor(named: "wrong_keys")!)
    }
    static var misplaced_letter: Color {
        Color(UIColor(named: "misplaced_letters")!)
    }
    static var correct: Color {
        Color(UIColor(named: "correct_letters")!)
    }
    static var unused: Color {
        Color(UIColor(named: "unused_letters")!)
    }
    static var enter_green: Color{
        Color(UIColor(named: "enter_green")!)
    }
    static var hard_mode_red: Color{
        Color(UIColor(named: "hard_mode_red")!)
    }
    static var interaction_color: Color{
        Color(UIColor(named: "interaction_color")!)
    }
    static var systemBackground: Color {
        Color(.systemBackground)
    }
}
