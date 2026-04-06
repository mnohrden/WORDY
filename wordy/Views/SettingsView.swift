import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var csManager: ColorSchemeManager
    @EnvironmentObject var dm: GameDataModel
    @EnvironmentObject var cm: ChallengeManager
    @Environment(\.dismiss) var dismiss
    @State private var showCopied = false
    @State private var showInvalidSeed = false
    var body: some View {
        NavigationView {
                    VStack {
                        //hard mode
                        GeometryReader { geometry in
                            HStack(spacing: 10) {
                                Text("Hard Mode")
                                    .font(.title3.bold())
                                    .foregroundColor(Color.hard_mode_red)
                                    .frame(width: geometry.size.width * 0.7, alignment: .leading)
                                Spacer()
                                Toggle("", isOn: $dm.hardMode)
                                    .labelsHidden()
                                    .frame(width: 51)
                            }
                            .frame(width: geometry.size.width)
                        }
                        .frame(height: 44)
                        .padding(.horizontal)
                        
                        Divider()
                        
                        // MARK: - Challenge Mode Section
                        VStack(spacing: 12) {
                            Text("Challenge Mode")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Text("Play the same words as your friends")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            if cm.isActive, let seed = cm.currentSeed {
                                // Active challenge display
                                VStack(spacing: 10) {
                                    Text("Your Code")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    HStack(spacing: 4) {
                                        ForEach(Array(seed), id: \.self) { digit in
                                            Text(String(digit))
                                                .font(.system(size: 32, weight: .bold, design: .monospaced))
                                                .frame(width: 44, height: 52)
                                                .background(Color.correct.opacity(0.3))
                                                .cornerRadius(8)
                                        }
                                    }
                                    
                                    Button {
                                        UIPasteboard.general.string = seed
                                        showCopied = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                            showCopied = false
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: showCopied ? "checkmark" : "doc.on.doc")
                                            Text(showCopied ? "Copied!" : "Copy Code")
                                        }
                                        .font(.subheadline.bold())
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.join_green)
                                        .cornerRadius(8)
                                    }
                                    
                                    Text("Round \(cm.currentRound + 1)")
                                        .font(.headline)
                                        .padding(.top, 4)
                                    
                                    Button {
                                        cm.leaveChallenge()
                                        dm.newGame()
                                    } label: {
                                        Text("Leave Challenge")
                                            .font(.subheadline.bold())
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(Color.hard_mode_red)
                                            .cornerRadius(8)
                                    }
                                }
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                                .padding(.horizontal)
                                
                            } else {
                                // Not in a challenge — show create/join options
                                VStack(spacing: 14) {
                                    Button {
                                        cm.startNewChallenge()
                                        dm.newGame()
                                    } label: {
                                        HStack {
                                            Image(systemName: "plus.circle.fill")
                                            Text("Create Challenge")
                                        }
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Color.join_green)
                                        .cornerRadius(10)
                                    }
                                    
                                    Text("or join with a code")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    HStack(spacing: 8) {
                                        TextField("4-digit code", text: $cm.seedInput)
                                            .keyboardType(.numberPad)
                                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                                            .multilineTextAlignment(.center)
                                            .frame(height: 44)
                                            .background(Color(.secondarySystemBackground))
                                            .cornerRadius(8)
                                            .onChange(of: cm.seedInput) { newValue in
                                                // Limit to 4 digits
                                                let filtered = newValue.filter { $0.isNumber }
                                                if filtered.count > 4 {
                                                    cm.seedInput = String(filtered.prefix(4))
                                                } else {
                                                    cm.seedInput = filtered
                                                }
                                            }
                                        
                                        Button {
                                            if cm.joinChallenge(seed: cm.seedInput) {
                                                cm.seedInput = ""
                                                dm.newGame()
                                            } else {
                                                showInvalidSeed = true
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                    showInvalidSeed = false
                                                }
                                            }
                                        } label: {
                                            Text("Join")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 20)
                                                .frame(height: 44)
                                                .background(cm.seedInput.count == 4 ? Color.join_green : Color.gray)
                                                .cornerRadius(8)
                                        }
                                        .disabled(cm.seedInput.count != 4)
                                    }
                                    .padding(.horizontal)
                                    
                                    if showInvalidSeed {
                                        Text("Enter a valid 4-digit code")
                                            .font(.caption)
                                            .foregroundColor(Color.hard_mode_red)
                                    }
                                }
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                        }
                        
                        Divider()
                        
                        Text("Change Theme")
                            .font(.title3)
                            .fontWeight(.bold)
                        Picker("Display Mode", selection: $csManager.colorScheme) {
                            Text("Dark").tag(ColorScheme.dark)
                            Text("Light").tag(ColorScheme.light)
                            Text("System").tag(ColorScheme.unspecified)
                        }
                        .pickerStyle(.segmented)
                        Text(
                            """
                        """
                        )
                        Divider()
                        Text("Help")
                            .font(.title3)
                            .fontWeight(.bold)
                        Text(
                    """
                    
                    Guess the word in 6 tries.
                    
                    Each guess must be a valid 5 letter word. Hit the enter button to submit.
                    
                    After each guess, the color of the tiles will change to show how close your guess was to the word.
                    """
                            )
                            .font(.callout)
                            VStack(alignment: .leading) {
                                Image("games")
                                    .resizable()
                                    .scaledToFit()
                                    .scaleEffect(0.9)
                                Text("None of the letters are in the word.")
                                    .font(.callout)
                                Image("wordy")
                                    .resizable()
                                    .scaledToFit()
                                    .scaleEffect(0.9)
                                Text("The **R** is in the word, but in the wrong spot.")
                                    .font(.callout)
                                Image("guess")
                                    .resizable()
                                    .scaledToFit()
                                    .scaleEffect(0.9)
                                Text("The **U** is in the word, and in the correct spot.")
                                    .font(.callout)
                            }
                    }.padding()
                    .navigationTitle("Options")
                    .font(.title3)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                dismiss()
                            } label: {
                                Text("✗")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.interaction_color)
                            }
                        }
                    }
                }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(ColorSchemeManager())
            .environmentObject(GameDataModel())
            .environmentObject(ChallengeManager())
    }
}
