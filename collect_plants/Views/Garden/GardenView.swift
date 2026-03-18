import SwiftUI

extension Notification.Name {
    static let furniturePurchased = Notification.Name("furniturePurchased")
}

struct GardenView: View {
    @State private var viewModel = GardenViewModel()
    @State private var showShop = false

    var body: some View {
        ZStack {
            // 背景グラデーション
            LinearGradient(
                colors: [
                    Color(red: 0.42, green: 0.65, blue: 0.35),
                    Color(red: 0.55, green: 0.78, blue: 0.42),
                    Color(red: 0.48, green: 0.72, blue: 0.38)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // MARK: - 庭グリッド（画面いっぱい・背景として配置）
            GardenGridView(
                plantCount: viewModel.gardenPlantCount,
                ownedFurnitureIDs: viewModel.ownedFurnitureIDs,
                critters: viewModel.gardenCritters
            )
            .ignoresSafeArea(edges: .bottom)

            // MARK: - UI オーバーレイ
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    // タイトルバー
                    HStack {
                        Text("庭")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        Text("🌿 \(viewModel.uniquePlants.count)種")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(.ultraThinMaterial))
                            .overlay(Capsule().stroke(Color.white.opacity(0.7), lineWidth: 1.5))
                        Button {
                            showShop = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "bag.fill")
                                Text("ショップ")
                                    .font(.caption.bold())
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(.ultraThinMaterial))
                            .overlay(Capsule().stroke(Color.white.opacity(0.7), lineWidth: 1.5))
                        }
                    }
                    .padding(.horizontal, 16)

                    // レベル・ポイントバー
                    GardenLevelView(
                        points: viewModel.points,
                        level: viewModel.level,
                        nextLevelPoints: viewModel.nextLevelPoints
                    )
                }
                .padding(.top, 4)
                .padding(.bottom, 8)
                .background(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.25),
                            Color.black.opacity(0.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                Spacer()

                // 植物ゼロ時の案内
                if viewModel.uniquePlants.isEmpty {
                    VStack(spacing: 12) {
                        Text("🌱")
                            .font(.system(size: 48))
                        Text("植物を登録すると\n庭に植物が咲きます")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.darkGreen)
                            .multilineTextAlignment(.center)
                    }
                    .padding(24)
                    .background(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial))
                    Spacer()
                }

                // 動物来訪バナー
                if let animal = viewModel.visitingAnimal {
                    HStack(spacing: 12) {
                        Text(animal)
                            .font(.system(size: 36))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("来訪者")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("やってきました！")
                                .font(.headline)
                                .foregroundColor(AppTheme.darkGreen)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .fill(AppTheme.paleYellow)
                            .shadow(color: Color.yellow.opacity(0.2), radius: 6, x: 0, y: 2)
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
            }
        }
        .onAppear {
            viewModel.loadGarden()
        }
        .onReceive(NotificationCenter.default.publisher(for: .furniturePurchased)) { _ in
            viewModel.loadGarden()
        }
        .sheet(isPresented: $showShop) {
            ItemShopView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            // Plants Count
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(AppTheme.headerGradient)
                    .shadow(color: AppTheme.accentGreen.opacity(0.2), radius: 8, x: 0, y: 3)

                VStack(spacing: 6) {
                    HStack(alignment: .bottom, spacing: 4) {
                        Text("\(viewModel.uniquePlants.count)")
                            .font(.system(size: 56, weight: .bold))
                            .foregroundColor(AppTheme.darkGreen)
                        Text("種")
                            .font(.title2.bold())
                            .foregroundColor(AppTheme.darkGreen)
                            .padding(.bottom, 8)
                    }
                    Text("の植物を展示中")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.darkGreen.opacity(0.7))

                    HStack(spacing: 4) {
                        ForEach(0..<min(viewModel.uniquePlants.count, 5), id: \.self) { _ in
                            Image(systemName: "leaf.fill")
                                .font(.caption)
                                .foregroundColor(AppTheme.accentGreen)
                        }
                    }
                }
                .padding(.vertical, 20)
            }

            // Points Card
            NavigationLink(destination: ItemShopView()) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "wallet.pass.fill")
                                .font(.title3)
                                .foregroundColor(AppTheme.accentGreen)
                            Text("所持ポイント")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.darkGreen)
                        }
                        HStack(spacing: 4) {
                            Text("\(viewModel.totalPoints)")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(AppTheme.darkGreen)
                            Text("P")
                                .font(.headline)
                                .foregroundColor(AppTheme.darkGreen.opacity(0.7))
                                .padding(.top, 6)
                        }
                    }
                    Spacer()
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.darkGreen)
                        Text("交換")
                            .font(.caption)
                            .foregroundColor(AppTheme.darkGreen)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                        .fill(AppTheme.primaryGradient)
                        .shadow(color: AppTheme.accentGreen.opacity(0.15), radius: 6, x: 0, y: 2)
                )
            }
            .foregroundColor(.primary)
        }
    }
}

#Preview {
    GardenView()
}
