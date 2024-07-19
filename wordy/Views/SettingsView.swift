import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var csManager: ColorSchemeManager
    @EnvironmentObject var dm: GameDataModel
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView {
                    VStack {
                        //hard mode code
                        Toggle("Hard Mode", isOn: $dm.hardMode)
                        Text("Change Theme")
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
                            Text(
                    """
                    
                    Guess the word in 6 tries.
                    
                    Each guess must be a valid 5 letter word. Hit the enter button to submit.
                    
                    After each guess, the color of the tiles will change to show how close your guess was to the word.
                    
                    """
                            )
                            .font(.callout)
                            Divider()
                            Text("Examples")
                                .font(/*@START_MENU_TOKEN@*/.title3/*@END_MENU_TOKEN@*/)
                                .fontWeight(.bold)
                            VStack(alignment: .leading) {
                                Image("games")
                                    .resizable()
                                    .scaledToFit()
                                Text("None of the letters are in the word.")
                                    .font(.callout)
                                Image("wordy")
                                    .resizable()
                                    .scaledToFit()
                                Text("The **R** is in the word, but in the wrong spot.")
                                    .font(.callout)
                                Image("guess")
                                    .resizable()
                                    .scaledToFit()
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
                                    .foregroundColor(Color.interaction)
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
