import SwiftUI

struct StepsDetailView: View {
    @State private var viewModel = MapViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea(edges: .bottom)

                ScrollView {
                    VStack(spacing: 16) {
                        todayStatsSection
                        totalPointsSection
                        stepHistorySection
                        Spacer(minLength: 20)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("歩数")
                        .font(.headline)
                        .foregroundColor(AppTheme.darkGreen)
                }
            }
            .toolbarBackground(AppTheme.cardBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                Task {
                    await viewModel.refreshTodaySteps()
                    await viewModel.loadStepHistory()
                }
            }
        }
    }

    // MARK: - Today's Stats Section
    private var todayStatsSection: some View {
        HStack(spacing: 12) {
            stepsCard
            pointsCard
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius)
    }

    // MARK: - Steps Card
    private var stepsCard: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: "figure.walk")
                    .font(.title3)
                    .foregroundColor(AppTheme.accentGreen)
                Text("今日の歩数")
                    .font(.headline)
                    .foregroundColor(AppTheme.darkGreen)
                Spacer()
            }
            HStack(alignment: .bottom, spacing: 2) {
                Text("\(viewModel.formatSteps(viewModel.todaySteps))")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(AppTheme.darkGreen)
                Text("歩")
                    .font(.headline)
                    .foregroundColor(AppTheme.darkGreen.opacity(0.7))
                    .padding(.bottom, 6)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                .fill(Color.white)
        )
    }

    // MARK: - Points Card
    private var pointsCard: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.title3)
                    .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0))
                Text("ポイント")
                    .font(.headline)
                    .foregroundColor(AppTheme.darkGreen)
                Spacer()
            }
            HStack(alignment: .bottom, spacing: 2) {
                Text("\(viewModel.todayPoints)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0))
                Text("P")
                    .font(.headline)
                    .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.7))
                    .padding(.bottom, 6)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                .fill(Color.white)
        )
    }

    // MARK: - Total Points Section
    private var totalPointsSection: some View {
        NavigationLink(destination: ItemShopView()) {
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: "wallet.pass.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("所持ポイント")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        HStack(spacing: 2) {
                            Text("\(viewModel.totalPoints)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            Text("P")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                Spacer()
                VStack(spacing: 4) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    Text("交換")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(AppTheme.primaryGradient)
            .cornerRadius(AppTheme.cornerRadius)
            .padding()
            .background(AppTheme.cardBackground)
        }
    }

    // MARK: - Step History Section
    private var stepHistorySection: some View {
        Group {
            if !viewModel.stepHistory.isEmpty {
                VStack(spacing: 12) {
                    HStack {
                        Text("7日間の歩数")
                            .font(.headline)
                            .foregroundColor(AppTheme.darkGreen)
                        Spacer()
                    }

                    stepHistoryChart
                }
                .padding()
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.cornerRadius)
                .padding()
            }
        }
    }

    // MARK: - Step History Chart
    private var stepHistoryChart: some View {
        VStack(spacing: 12) {
            // Values on top
            HStack(spacing: 4) {
                ForEach(viewModel.stepHistory, id: \.0) { date, steps in
                    VStack(spacing: 0) {
                        Text("\(viewModel.formatSteps(steps))")
                            .font(.caption2)
                            .foregroundColor(AppTheme.darkGreen)
                            .frame(height: 16)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 16)

            // Bars
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(viewModel.stepHistory, id: \.0) { date, steps in
                    let maxSteps = viewModel.stepHistory.map { $0.1 }.max() ?? 1
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.primaryGreen)
                        .frame(height: CGFloat(max(30, Double(steps) / Double(maxSteps) * 120)))
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 150)

            // Dates on bottom
            HStack(spacing: 4) {
                ForEach(viewModel.stepHistory, id: \.0) { date, steps in
                    Text(viewModel.formatDate(date))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(AppTheme.smallCornerRadius)
    }
}

#Preview {
    StepsDetailView()
}
