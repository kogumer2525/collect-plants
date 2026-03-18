import SwiftUI

// MARK: - 庭のレベル・ポイント表示バー
struct GardenLevelView: View {
    let points: Int
    let level: Int
    let nextLevelPoints: Int

    var body: some View {
        HStack(spacing: 12) {
            // レベルバッジ
            ZStack {
                Circle()
                    .fill(AppTheme.darkGreen)
                    .frame(width: 44, height: 44)
                VStack(spacing: 0) {
                    Text("Lv")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                    Text("\(level)")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(.white)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("庭レベル \(level)")
                        .font(.caption.bold())
                        .foregroundColor(AppTheme.darkGreen)
                    Spacer()
                    Text("\(points) / \(nextLevelPoints) pt")
                        .font(.caption2)
                        .foregroundColor(AppTheme.darkGreen.opacity(0.7))
                }

                // 経験値バー
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppTheme.primaryGreen.opacity(0.3))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [AppTheme.accentGreen, AppTheme.darkGreen],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geo.size.width * progressRatio,
                                height: 8
                            )
                            .animation(.easeInOut(duration: 0.5), value: progressRatio)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
    }

    private var progressRatio: CGFloat {
        guard nextLevelPoints > 0 else { return 1.0 }
        return min(CGFloat(points) / CGFloat(nextLevelPoints), 1.0)
    }
}

#Preview {
    ZStack {
        Color.green.ignoresSafeArea()
        VStack {
            GardenLevelView(points: 75, level: 2, nextLevelPoints: 100)
            GardenLevelView(points: 30, level: 1, nextLevelPoints: 50)
        }
    }
}
