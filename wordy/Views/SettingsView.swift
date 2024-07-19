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
                        Spacer()
                    }.padding()
                    .navigationTitle("Options")
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(ColorSchemeManager())
            .environmentObject(GameDataModel())
    }
}
