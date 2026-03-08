import SwiftUI

struct DictionaryView: View {
    @State private var viewModel = DictionaryViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.uniquePlants.isEmpty {
                    ZStack {
                        AppTheme.background.ignoresSafeArea()
                        VStack(spacing: 16) {
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 64))
                                .foregroundColor(AppTheme.primaryGreen)
                            Text("まだ植物が登録されていません")
                                .font(.headline)
                                .foregroundColor(AppTheme.darkGreen)
                            Text("「探す」タブで植物を撮影して登録しましょう")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    }
                } else {
                    List(viewModel.uniquePlants) { plant in
                        NavigationLink(destination: PlantDetailView(plant: plant)) {
                            PlantRowView(plant: plant)
                        }
                        .listRowBackground(AppTheme.cardBackground)
                    }
                    .scrollContentBackground(.hidden)
                    .background(AppTheme.background)
                }
            }
            .navigationTitle("図鑑")
            .toolbarBackground(AppTheme.cardBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                viewModel.loadPlants()
            }
        }
    }
}

struct PlantRowView: View {
    let plant: PlantRecord

    var body: some View {
        HStack(spacing: 12) {
            if let uiImage = UIImage(data: plant.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 64)
                    .cornerRadius(AppTheme.smallCornerRadius)
                    .clipped()
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                            .stroke(AppTheme.primaryGreen, lineWidth: 1.5)
                    )
            } else {
                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                    .fill(AppTheme.primaryGreen.opacity(0.3))
                    .frame(width: 64, height: 64)
                    .overlay(
                        Image(systemName: "leaf.fill")
                            .foregroundColor(AppTheme.accentGreen)
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(plant.plantName)
                    .font(.headline)
                    .foregroundColor(AppTheme.darkGreen)
                Text(plant.scientificName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
                Text(plant.locationName.isEmpty ? "場所不明" : plant.locationName)
                    .font(.caption2)
                    .foregroundColor(AppTheme.accentGreen)
            }
        }
        .padding(.vertical, 6)
    }
}

struct PlantDetailView: View {
    let plant: PlantRecord

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if let uiImage = UIImage(data: plant.imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 280)
                        .clipped()
                        .overlay(
                            LinearGradient(
                                colors: [.clear, AppTheme.darkGreen.opacity(0.4)],
                                startPoint: .center,
                                endPoint: .bottom
                            )
                        )
                }

                VStack(spacing: 20) {
                    VStack(spacing: 6) {
                        HStack {
                            Image(systemName: "leaf.fill")
                                .foregroundColor(AppTheme.accentGreen)
                            Text(plant.plantName)
                                .font(.title2.bold())
                                .foregroundColor(AppTheme.darkGreen)
                        }
                        Text(plant.scientificName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                    .padding(.top, 20)

                    VStack(spacing: 0) {
                        DetailRow(icon: "mappin.circle.fill", label: "発見場所", value: plant.locationName.isEmpty ? "不明" : plant.locationName)
                        Divider().padding(.horizontal).background(AppTheme.primaryGreen.opacity(0.3))
                        DetailRow(icon: "calendar", label: "発見日", value: plant.date.formatted(date: .long, time: .shortened))
                        Divider().padding(.horizontal).background(AppTheme.primaryGreen.opacity(0.3))
                        DetailRow(icon: "checkmark.seal.fill", label: "信頼度", value: plant.confidence.confidencePercentage)
                    }
                    .natureCardStyle()
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
        }
        .background(AppTheme.background)
        .navigationTitle(plant.plantName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.cardBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.accentGreen)
                .frame(width: 24)
            Text(label)
                .foregroundColor(.secondary)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(AppTheme.darkGreen)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
