import SwiftUI

struct StatsView: View {
    @EnvironmentObject var dm: GameDataModel
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        dm.showStats.toggle()
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.secondary)
                }
                .offset(x: 10, y: 5)
            }
            Text("STATISTICS")
                .font(.headline.weight(.bold))
            HStack(alignment: .top) {
                SingleStat(value: dm.currentStat.games,
                           text: "Played")
                if dm.currentStat.games != 0 {
                    SingleStat(value: Int(100 * dm.currentStat.wins/dm.currentStat.games),
                               text: "Win %")
                }
                SingleStat(value: dm.currentStat.streak,
                           text: "Current Streak")
                    .fixedSize(horizontal: false, vertical: true)
                SingleStat(value: dm.currentStat.maxStreak,
                           text: "MAX Streak")
                    .fixedSize(horizontal: false, vertical: true)
            }
            Text("GUESS DISTRIBUTION")
                .font(.headline.weight(.bold))
            VStack(spacing: 5) {
                ForEach (0..<6) { index in
                    HStack {
                        Text("\(index + 1)")
                        if dm.currentStat.frequencies[index] == 0 {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(Color.wrong)
                                .frame(width: 22, height: 20)
                                .overlay(
                                    Text("0")
                                        .foregroundColor(.white)
                                )
                        } else {
                            if let maxValue = dm.currentStat.frequencies.max() {
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .fill((dm.tryIndex == index && dm.gameOver)
                                          ? Color.correct
                                          : Color.wrong)
                                    .frame(width: CGFloat(dm.currentStat.frequencies[index])
                                           / CGFloat(maxValue) * 210,
                                           height: 20)
                                    .overlay(
                                        Text("\(dm.currentStat.frequencies[index])")
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 5),
                                        alignment: .trailing)
                            }
                        }
                        Spacer()
                    }
                }
                if dm.gameOver {
                    HStack {
                        Spacer()
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal, 40)
        .frame(width: 320, height: 370)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.2), radius: 20, y: 8)
        .padding()
        .offset(y: -70)
    }
}

struct SingleStat: View {
    let value: Int
    let text: String
    var body: some View {
        VStack {
            Text("\(value)")
                .font(.largeTitle)
            Text(text)
                .font(.caption)
                .frame(width: 50)
                .multilineTextAlignment(.center)
        }
    }
}
