import SwiftUI

struct GameView: View {
    @EnvironmentObject var dm: GameDataModel
    @State private var showSettings = false
    @State private var showHelp = false
    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    if Global.screenHeight < 600 {
                        Text("")
                    }
                    Spacer()
                    VStack(spacing: 3) {
                        ForEach(0...5, id: \.self) { index in
                            GuessView(guess: $dm.guesses[index])
                                .modifier(Shake(animatableData: CGFloat(dm.incorrectAttempts[index])))
                        }
                    }
                    .frame(width: Global.boardWidth, height: 6 * Global.boardWidth / 5)
                    Spacer()
                    Keyboard()
                        .scaleEffect(Global.keyboardScale)
                        .padding(.top)
                    Spacer()
                }
                .navigationBarTitleDisplayMode(.inline)
                .overlay(alignment: .top) {
                    if let msgText = dm.msgText {
                        MsgView(msgText: msgText)
                            .offset(y: 20)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack {
                            Button(action: {
                                if !dm.hardMode || dm.gameOver {
                                    dm.newGame()
                                }
                            }) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 18, weight: .heavy))
                            }
                            .disabled(dm.hardMode && !dm.gameOver) // Disable the button when hard mode is enabled
                            .opacity((!dm.hardMode || dm.gameOver) ? 1 : 0.5)
                        }
                    }
                    ToolbarItem(placement: .principal) {
                        Text("WORDY")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(dm.hardMode ? Color(.hardModeRed) : .primary)
                            .minimumScaleFactor(0.5)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            Button {
                                showSettings.toggle()
                            } label: {
                                Image(systemName: "gearshape.fill")
                                .font(.system(size: 18, weight: .bold))
                            }
                        }
                    }
                }
                .sheet(isPresented: $showSettings) {
                SettingsView()
                }
            }
        }
    }
}
