import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var csManager: ColorSchemeManager
    @EnvironmentObject var dm: GameDataModel
    @EnvironmentObject var cm: ChallengeManager
    @Environment(\.dismiss) var dismiss
    @State private var showCopied = false
    @State private var showInvalidSeed = false
    @State private var showHelp = false
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Difficulty
                    VStack(spacing: 10) {
                        Text("Difficulty")
                            .font(.title3.bold())
                            .foregroundColor(dm.difficulty == 2 ? Color.hard_mode_red : .primary)
                        Picker("Difficulty", selection: $dm.difficulty) {
                            Text("Easy").tag(0)
                            Text("Medium").tag(1)
                            Text("Hard").tag(2)
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
                    )
                    .padding(.horizontal)

                    // MARK: - Challenge Mode Section
                    VStack(spacing: 12) {
                        Text("Challenge Mode")
                            .font(.title3.bold())

                        Text("Play the same words as your friends")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        if cm.isActive, let seed = cm.currentSeed {
                            VStack(spacing: 10) {
                                Text("Your Code")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                HStack(spacing: 6) {
                                    ForEach(Array(seed), id: \.self) { digit in
                                        Text(String(digit))
                                            .font(.system(size: 32, weight: .bold, design: .monospaced))
                                            .frame(width: 44, height: 52)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .fill(Color.correct.opacity(0.25))
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
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
                                    .background(
                                        Capsule(style: .continuous).fill(Color.join_green)
                                    )
                                    .shadow(color: Color.join_green.opacity(0.3), radius: 6, y: 2)
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
                                        .background(
                                            Capsule(style: .continuous).fill(Color.hard_mode_red)
                                        )
                                        .shadow(color: Color.hard_mode_red.opacity(0.3), radius: 6, y: 2)
                                }
                            }
                        } else {
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
                                    .background(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(Color.enter_green)
                                    )
                                    .shadow(color: Color.enter_green.opacity(0.3), radius: 6, y: 2)
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
                                        .background(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .fill(.ultraThinMaterial)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .strokeBorder(Color.primary.opacity(0.1), lineWidth: 0.5)
                                        )
                                        .onChange(of: cm.seedInput) { newValue in
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
                                            .background(
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .fill(cm.seedInput.count == 4 ? Color.join_green : Color.gray)
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                            .shadow(color: cm.seedInput.count == 4 ? Color.join_green.opacity(0.3) : .clear, radius: 6, y: 2)
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
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
                    )
                    .padding(.horizontal)

                    // MARK: - Theme
                    VStack(spacing: 12) {
                        Text("Change Theme")
                            .font(.title3.bold())
                        Picker("Display Mode", selection: $csManager.colorScheme) {
                            Text("Dark").tag(ColorScheme.dark)
                            Text("Light").tag(ColorScheme.light)
                            Text("System").tag(ColorScheme.unspecified)
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
                    )
                    .padding(.horizontal)

                    // MARK: - Help
                    Button {
                        showHelp = true
                    } label: {
                        HStack {
                            Text("Help")
                                .font(.title3.bold())
                            Spacer()
                            Image(systemName: "info.circle.fill")
                                .font(.title3)
                                .symbolRenderingMode(.hierarchical)
                        }
                        .foregroundColor(.primary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
                    )
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(Color.interaction_color)
                    }
                }
            }
            .sheet(isPresented: $showHelp) {
                HelpPopup()
            }
        }
    }
}

// MARK: - Help Popup

struct HelpPopup: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Guess the word in 6 tries.\n\nEach guess must be a valid 5 letter word. Hit the enter button to submit.\n\nAfter each guess, the color of the tiles will change to show how close your guess was to the word.")
                        .font(.callout)

                    VStack(alignment: .leading, spacing: 8) {
                        Image("games")
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 50)
                        Text("None of the letters are in the word.")
                            .font(.callout)
                        Image("wordy")
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 50)
                        Text("The **R** is in the word, but in the wrong spot.")
                            .font(.callout)
                        Image("guess")
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 50)
                        Text("The **U** is in the word, and in the correct spot.")
                            .font(.callout)
                    }

                    Divider()

                    Text("Difficulty Modes")
                        .font(.headline)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("**Easy** — No restrictions. Restart anytime.")
                        Text("**Medium** — You cannot restart once you begin a game.")
                        Text("**Hard** — No restarts. Gray letters cannot be reused. Yellow letters must appear in a new position. Blue letters must stay in place. Constraints build across guesses.")
                    }
                    .font(.callout)
                    .foregroundColor(.secondary)
                }
                .padding()
            }
            .navigationTitle("How to Play")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(.secondary)
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
