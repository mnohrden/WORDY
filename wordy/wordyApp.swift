import SwiftUI

//start app
@main
struct wordyApp: App {
    //init viewModels
    @StateObject var dm = GameDataModel()
    @StateObject var csManager = ColorSchemeManager()
    @StateObject var challengeManager = ChallengeManager()
    var body: some Scene {
        WindowGroup {
            GameView()
                .environmentObject(dm)
                .environmentObject(csManager)
                .environmentObject(challengeManager)
                .onAppear {
                    csManager.applyColorScheme()
                    dm.challengeManager = challengeManager
                    if challengeManager.isActive {
                        dm.newGame()
                    }
                }
        }
    }
}