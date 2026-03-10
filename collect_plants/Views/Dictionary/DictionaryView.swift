import SwiftUI
import MapKit
import CoreLocation

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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("図鑑")
                        .font(.headline)
                        .foregroundColor(AppTheme.darkGreen)
                }
            }
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
    @State private var viewModel: PlantDetailViewModel

    init(plant: PlantRecord) {
        self.plant = plant
        _viewModel = State(initialValue: PlantDetailViewModel(plant: plant))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                bookView
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
                    .padding(.bottom, 8)

                // Wikipedia Attribution
                VStack(spacing: 2) {
                    Text("この説明文の一部はWikipediaの記事を元にしています。")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                    Text("Source: Wikipedia (https://www.wikipedia.org/)")
                        .font(.system(size: 7))
                        .foregroundColor(.secondary)
                    Text("Text is available under the Creative Commons Attribution-ShareAlike License (CC BY-SA).")
                        .font(.system(size: 7))
                        .foregroundColor(.secondary)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
                .padding(.top, 8)
                .padding(.bottom, 12)

                // MARK: - Map Display
                locationMapView
                    .frame(height: 140)
                    .padding(.horizontal, 15)
                    .padding(.top, 12)
                    .padding(.bottom, 16)
            }
        }
        .background(AppTheme.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("植物図鑑")
                    .font(.headline)
                    .foregroundColor(AppTheme.darkGreen)
            }
        }
        .toolbarBackground(AppTheme.cardBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .task {
            await viewModel.fetchWikipediaInfo()
        }
    }

    // MARK: - Book Layout

    private var bookView: some View {
        HStack(alignment: .top, spacing: 0) {
            leftColumn
                .frame(maxWidth: .infinity)
                .padding(.leading, 20)
                .padding(.trailing, 8)
                .padding(.vertical, 24)

            rightColumn
                .frame(maxWidth: .infinity)
                .padding(.leading, 12)
                .padding(.trailing, 32)
                .padding(.vertical, 24)
        }
        .background(
            Image("zukan_back")
                .resizable()
                .scaledToFill()
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }

    // MARK: - Left Column

    private var leftColumn: some View {
        VStack(spacing: 6) {
            if !viewModel.japaneseName.isEmpty {
                Text(viewModel.japaneseName.hiraganaToKatakana)
                    .font(.custom("craftmincho", size: 20))
                    .foregroundColor(AppTheme.darkGreen)
            }

            if let uiImage = UIImage(data: plant.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 220)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color(red: 0.82, green: 0.78, blue: 0.70), lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 3, x: 1, y: 2)
                    .padding(.vertical, 4)
            }

            Text(plant.plantName)
                .font(.custom("craftmincho", size: 18))
                .foregroundColor(AppTheme.darkGreen)

            Text(plant.scientificName)
                .font(.custom("craftmincho", size: 12))
                .italic()
                .foregroundColor(.secondary)

            HStack(spacing: 4) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(AppTheme.accentGreen)
                    .font(.system(size: 12))
                Text("信頼度 \(plant.confidence.confidencePercentage)")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(.top, 2)
        }
    }

    // MARK: - Right Column

    private var rightColumn: some View {
        VStack(alignment: .leading, spacing: 8) {
            zukanInfoRow(icon: "mappin.circle.fill", label: "発見場所",
                         value: plant.locationName.isEmpty ? "不明" : plant.locationName)
            zukanInfoRow(icon: "calendar", label: "発見日",
                         value: plant.date.formatted(date: .long, time: .shortened))

            Divider()
                .padding(.vertical, 4)

            Text("解説")
                .font(.custom("craftmincho", size: 15))
                .foregroundColor(AppTheme.darkGreen)

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)
            } else {
                Text(viewModel.plantDescription)
                    .font(.custom("craftmincho", size: 11))
                    .foregroundColor(.primary.opacity(0.85))
                    .lineSpacing(3)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Helper

    private func zukanInfoRow(icon: String, label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.accentGreen)
                .font(.system(size: 13))
                .frame(width: 16)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.custom("craftmincho", size: 12))
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.custom("craftmincho", size: 12))
                    .foregroundColor(.primary.opacity(0.85))
            }
        }
    }

    // MARK: - Map View

    private var locationMapView: some View {
        ZStack {
            Map(position: .constant(.region(
                MKCoordinateRegion(
                    center: CLLocationCoordinate2D(
                        latitude: plant.latitude,
                        longitude: plant.longitude
                    ),
                    span: MKCoordinateSpan(
                        latitudeDelta: 0.05,
                        longitudeDelta: 0.05
                    )
                )
            ))) {
                Annotation("", coordinate: CLLocationCoordinate2D(
                    latitude: plant.latitude,
                    longitude: plant.longitude
                )) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(AppTheme.primaryGreen)
                        .font(.system(size: 28))
                }
            }
            .mapStyle(.standard)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppTheme.darkGreen, lineWidth: 2)
            )
        }
    }
}
