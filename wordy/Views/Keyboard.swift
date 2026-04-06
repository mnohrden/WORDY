import SwiftUI

struct Keyboard: View {
    @EnvironmentObject var dm: GameDataModel
    var topRowArray = "QWERTYUIOP".map{ String($0) }
    var secondRowArray = "ASDFGHJKL".map{ String($0) }
    var thirdRowArray = "ZXCVBNM".map{ String($0) }
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                ForEach(topRowArray, id: \.self) { letter in
                    LetterButtonView(letter: letter)
                }
                .disabled(dm.disabledKeys)
                .opacity(dm.disabledKeys ? 0.6 : 1)
            }
            HStack(spacing: 4) {
                ForEach(secondRowArray, id: \.self) { letter in
                    LetterButtonView(letter: letter)
                }
            }
            .disabled(dm.disabledKeys)
            .opacity(dm.disabledKeys ? 0.6 : 1)
            HStack(spacing: 4) {
                Button {
                    dm.enterWord()
                } label: {
                    Text("Enter")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(width: 58, height: 44)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(Color.enter_green)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        .shadow(color: .black.opacity(0.12), radius: 1, y: 1)
                }
                .disabled(dm.currentWord.count < 5 || !dm.inPlay)
                .opacity((dm.currentWord.count < 5 || !dm.inPlay) ? 0.6 : 1)
                ForEach(thirdRowArray, id: \.self) { letter in
                    LetterButtonView(letter: letter)
                }
                .disabled(dm.disabledKeys)
                .opacity(dm.disabledKeys ? 0.6 : 1)
                Button {
                    dm.removeLetterFromCurrentWord()
                } label: {
                    Image(systemName: "delete.backward")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(width: 40, height: 44)
                        .foregroundColor(.primary)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(Color(.systemGray3))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        .shadow(color: .black.opacity(0.12), radius: 1, y: 1)
                }
                .disabled(!dm.inPlay || dm.currentWord.count == 0)
                .opacity((!dm.inPlay || dm.currentWord.count == 0) ? 0.6 : 1)
            }
        }
        .padding(.horizontal, 2)
    }
}
