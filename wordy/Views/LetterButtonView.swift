import SwiftUI

struct LetterButtonView: View {
    @EnvironmentObject var dm: GameDataModel
    var letter: String
    var body: some View {
        Button {
            dm.addToCurrentWord(letter)
        } label: {
            Text(letter)
                .font(.system(size: 20))
                .frame(width: 35, height: 50)
                .background(dm.keyColors[letter])
                .foregroundColor(.primary)
                .cornerRadius(5)
        }
        .buttonStyle(.plain)
    }
}
