import SwiftUI

struct Keyboard: View {
    @EnvironmentObject var dm: GameDataModel
    var topRowArray = "QWERTYUIOP".map{ String($0) }
    var secondRowArray = "ASDFGHJKL".map{ String($0) }
    var thirdRowArray = "ZXCVBNM".map{ String($0) }
    var body: some View {
        VStack {
            HStack(spacing: 2) {
                ForEach(topRowArray, id: \.self) { letter in
                    LetterButtonView(letter: letter)
                        .background()
                }
                .disabled(dm.disabledKeys)
                .opacity(dm.disabledKeys ? 0.6 : 1)
            }
            HStack(spacing: 2) {
                ForEach(secondRowArray, id: \.self) { letter in
                    LetterButtonView(letter: letter)
                }
            }
            .disabled(dm.disabledKeys)
            .opacity(dm.disabledKeys ? 0.6 : 1)
            HStack(spacing: 2) {
                Button {
                    dm.enterWord()
                } label: {
                    Text("Enter")
                    
                }
                .font(.system(size: 20))
                .frame(width: 60, height: 50)
                .foregroundColor(.primary)
                .background(Color.enter_green)
                .cornerRadius(5)
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
                    Image(systemName: "delete.backward.fill")
                        .font(.system(size: 20, weight: .heavy))
                        .frame(width: 40, height: 50)
                        .foregroundColor(.primary)
                        .background(Color.unused)
                        .cornerRadius(5)
                }
                .disabled(!dm.inPlay || dm.currentWord.count == 0)
                .opacity((!dm.inPlay || dm.currentWord.count == 0) ? 0.6 : 1)
            }
        }
    }
}
