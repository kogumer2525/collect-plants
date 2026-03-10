import SwiftUI

struct GardenView: View {
    @State private var viewModel = GardenViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection

                    if viewModel.uniquePlants.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "tree.fill")
                                .font(.system(size: 64))
                                .foregroundColor(AppTheme.primaryGreen)
                            Text("植物園はまだ空です")
                                .font(.headline)
                                .foregroundColor(AppTheme.darkGreen)
                            Text("植物を登録すると、ここに植物園が作られます")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(40)
                    } else {
                        gardenGrid
                    }

                    if let animal = viewModel.visitingAnimal {
                        animalSection(animal: animal)
                    }
                }
                .padding()
            }
            .background(AppTheme.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("植物園")
                        .font(.headline)
                        .foregroundColor(AppTheme.darkGreen)
                }
            }
            .toolbarBackground(AppTheme.cardBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                viewModel.loadGarden()
            }
        }
    }

    private var headerSection: some View {
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
    }

    private var gardenGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(viewModel.uniquePlants) { plant in
                VStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.primaryGreen.opacity(0.25))
                            .frame(width: 88, height: 88)
                        if let uiImage = UIImage(data: plant.imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(AppTheme.primaryGreen, lineWidth: 2)
                                )
                        } else {
                            Circle()
                                .fill(AppTheme.primaryGreen.opacity(0.4))
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Image(systemName: "leaf.fill")
                                        .font(.title2)
                                        .foregroundColor(AppTheme.accentGreen)
                                )
                        }
                    }
                    Text(plant.plantName)
                        .font(.caption.bold())
                        .foregroundColor(AppTheme.darkGreen)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                        .fill(AppTheme.cardBackground)
                        .shadow(color: AppTheme.accentGreen.opacity(0.1), radius: 4, x: 0, y: 2)
                )
            }
        }
    }

    private func animalSection(animal: String) -> some View {
        HStack(spacing: 16) {
            Text(animal)
                .font(.system(size: 40))
            VStack(alignment: .leading, spacing: 4) {
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
                .shadow(color: Color.yellow.opacity(0.15), radius: 6, x: 0, y: 2)
        )
    }
}
