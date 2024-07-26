import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var csManager: ColorSchemeManager
    @EnvironmentObject var dm: GameDataModel
    @Environment(\.dismiss) var dismiss
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
    }
}
