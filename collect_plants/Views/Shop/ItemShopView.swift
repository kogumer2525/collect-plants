import SwiftUI

struct ItemShopView: View {
    @State private var viewModel = ItemShopViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var showPurchaseAlert = false
    @State private var selectedFurniture: Furniture? = nil
    @State private var purchaseSuccess = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // Points Header
                        pointsHeaderSection

                        // Furniture Items
                        furnitureGridSection

                        Spacer(minLength: 20)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("アイテムショップ")
                        .font(.headline)
                        .foregroundColor(AppTheme.darkGreen)
                }
            }
            .toolbarBackground(AppTheme.cardBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                viewModel.load()
            }
            .alert("購入しました！", isPresented: $purchaseSuccess) {
                Button("OK") { }
            }
        }
    }

    // MARK: - Points Header
    private var pointsHeaderSection: some View {
        HStack {
            HStack(spacing: 12) {
                Image(systemName: "star.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0))
                VStack(alignment: .leading, spacing: 4) {
                    Text("所持ポイント")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack(spacing: 2) {
                        Text("\(viewModel.totalPoints)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(AppTheme.darkGreen)
                        Text("P")
                            .font(.headline)
                            .foregroundColor(AppTheme.darkGreen.opacity(0.7))
                    }
                }
            }
            Spacer()
        }
        .padding()
        .background(AppTheme.primaryGradient)
        .cornerRadius(AppTheme.cornerRadius)
    }

    // MARK: - Furniture Grid
    private var furnitureGridSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("アイテム一覧")
                    .font(.headline)
                    .foregroundColor(AppTheme.darkGreen)
                Spacer()
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(viewModel.allFurniture) { furniture in
                    furnitureCard(furniture)
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius)
    }

    // MARK: - Furniture Card
    private func furnitureCard(_ furniture: Furniture) -> some View {
        VStack(spacing: 8) {
            // Image
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                    .fill(Color.white)

                Image(furniture.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
            }
            .frame(height: 120)

            // Name
            Text(furniture.name)
                .font(.subheadline.bold())
                .foregroundColor(AppTheme.darkGreen)
                .lineLimit(1)

            // Cost
            HStack(spacing: 2) {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0))
                Text("\(furniture.cost)")
                    .font(.caption.bold())
                    .foregroundColor(AppTheme.darkGreen)
                Spacer()
            }

            // Count & Button
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("所持数")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("\(viewModel.getCount(forFurnitureId: furniture.id))")
                        .font(.headline)
                        .foregroundColor(AppTheme.darkGreen)
                }
                Spacer()

                Button(action: {
                    if viewModel.purchaseFurniture(furniture) {
                        purchaseSuccess = true
                    }
                }) {
                    Text("購入")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(viewModel.canAfford(furniture) ? AppTheme.accentGreen : Color.gray)
                        )
                }
                .disabled(!viewModel.canAfford(furniture))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(AppTheme.smallCornerRadius)
        .shadow(color: AppTheme.accentGreen.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    ItemShopView()
}
