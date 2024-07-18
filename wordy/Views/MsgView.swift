import SwiftUI

struct MsgView: View {
    let msgText: String
    var body: some View {
        Text(msgText)
            .foregroundColor(.systemBackground)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.primary))
    }
}
