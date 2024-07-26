import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text(
        """
        Guess the word in 6 tries.
        
        Each guess must be a valid 5 letter word. Hit the enter button to submit.
        
        After each guess, the color of the tiles will change to show how close your guess was to the word.
        """
                )
                Divider()
                Text("Examples")
                    .font(/*@START_MENU_TOKEN@*/.title3/*@END_MENU_TOKEN@*/)
                    .fontWeight(.bold)
                VStack(alignment: .leading) {
                    Image("games")
                        .resizable()
                        .scaledToFit()
                    Text("None of the letters are in the word.")
                    Image("wordy")
                        .resizable()
                        .scaledToFit()
                    Text("The **R** is in the word, but in the wrong spot.")
                    Image("guess")
                        .resizable()
                        .scaledToFit()
                    Text("The **U** is in the word, and in the correct spot.")
                }
            }
            .frame(width: min(Global.screenWidth - 40, 350))
            .navigationTitle("HOW TO PLAY")
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
                            .foregroundColor(Color.black)
                    }
                }
            }
        }
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}
