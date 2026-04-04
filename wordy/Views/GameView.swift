import SwiftUI

struct GameView: View {
    @EnvironmentObject var dm: GameDataModel
    @EnvironmentObject var cm: ChallengeManager
    @State private var showSettings = false
    @State private var showHelp = false
    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    if Global.screenHeight < 600 {
                        Text("")
                    }
                    // Challenge mode indicator
                    if cm.isActive, let seed = cm.currentSeed {
                        HStack(spacing: 6) {
                            Image(systemName: "person.2.fill")
                                .font(.caption2)
                            Text("Challenge \(seed)")
                                .font(.caption2.bold())
                            Text("•")
                                .font(.caption2)
                            Text("Round \(cm.currentRound + 1)")
                                .font(.caption2)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.enter_green)
                        .cornerRadius(12)
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