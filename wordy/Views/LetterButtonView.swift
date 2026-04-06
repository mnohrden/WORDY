import SwiftUI

struct LetterButtonView: View {
    @EnvironmentObject var dm: GameDataModel
    var letter: String
    var body: some View {
        Button {
            dm.addToCurrentWord(letter)
        } label: {
            Text(letter)
                .font(.system(size: 18, weight: .medium))
                .frame(width: 34, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(dm.keyColors[letter] ?? Color(.systemGray4))
                )
                .foregroundColor(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .shadow(color: .black.opacity(0.12), radius: 1, y: 1)
        }
        .buttonStyle(.plain)
    }
}
