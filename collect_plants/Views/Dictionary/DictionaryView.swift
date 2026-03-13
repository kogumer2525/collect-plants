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
                        NavigationLink(destination: PlantDetailView(plant: plant, allPlants: viewModel.uniquePlants)) {
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
                    Text("植物図鑑")
                        .font(.headline)
                        .foregroundColor(AppTheme.darkGreen)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(action: {
                            viewModel.sortOption = .dateNewest
                        }) {
                            HStack {
                                Text(SortOption.dateNewest.label)
                                if viewModel.sortOption == .dateNewest {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        Button(action: {
                            viewModel.sortOption = .japaneseNameAscending
                        }) {
                            HStack {
                                Text(SortOption.japaneseNameAscending.label)
                                if viewModel.sortOption == .japaneseNameAscending {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        Button(action: {
                            viewModel.sortOption = .englishNameAscending
                        }) {
                            HStack {
                                Text(SortOption.englishNameAscending.label)
                                if viewModel.sortOption == .englishNameAscending {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        Button(action: {
                            viewModel.sortOption = .locationAscending
                        }) {
                            HStack {
                                Text(SortOption.locationAscending.label)
                                if viewModel.sortOption == .locationAscending {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .foregroundColor(AppTheme.darkGreen)
                    }
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
                    .frame(width: 75, height: 75)
                    .cornerRadius(AppTheme.smallCornerRadius)
                    .clipped()
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                            .stroke(AppTheme.primaryGreen, lineWidth: 1.5)
                    )
            } else {
                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                    .fill(AppTheme.primaryGreen.opacity(0.3))
                    .frame(width: 75, height: 75)
                    .overlay(
                        Image(systemName: "leaf.fill")
                            .foregroundColor(AppTheme.accentGreen)
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(plant.japaneseName.isEmpty ? plant.plantName : plant.japaneseName)
                    .font(.headline)
                    .foregroundColor(AppTheme.darkGreen)
                Text(plant.plantName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(plant.locationName.isEmpty ? "場所不明" : plant.locationName)
                    .font(.caption)
                    .foregroundColor(AppTheme.accentGreen)
                Text(plant.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}

struct PlantDetailView: View {
    let allPlants: [PlantRecord]
    @State private var currentPlant: PlantRecord
    @State private var viewModel: PlantDetailViewModel
    @State private var showFullScreenImage = false

    init(plant: PlantRecord, allPlants: [PlantRecord]) {
        self.allPlants = allPlants
        _currentPlant = State(initialValue: plant)
        _viewModel = State(initialValue: PlantDetailViewModel(plant: plant))
    }

    private var currentIndex: Int? {
        allPlants.firstIndex(where: { $0.id == currentPlant.id })
    }

    private var canMovePrevious: Bool {
        guard let currentIndex else { return false }
        return currentIndex > 0
    }

    private var canMoveNext: Bool {
        guard let currentIndex else { return false }
        return currentIndex < allPlants.count - 1
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

                HStack(spacing: 12) {
                    Button(action: {
                        moveToPreviousPlant()
                    }) {
                        Text("←")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(canMovePrevious ? .white : .secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(canMovePrevious ? AppTheme.primaryGreen : AppTheme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .disabled(!canMovePrevious)

                    Button(action: {
                        moveToNextPlant()
                    }) {
                        Text("→")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(canMoveNext ? .white : .secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(canMoveNext ? AppTheme.primaryGreen : AppTheme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .disabled(!canMoveNext)
                }
                .padding(.horizontal, 15)
                .padding(.bottom, 20)
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
        .fullScreenCover(isPresented: $showFullScreenImage) {
            FullScreenImageView(imageData: currentPlant.imageData, isPresented: $showFullScreenImage)
        }
    }

    // MARK: - Book Layout

    private func moveToPreviousPlant() {
        guard let currentIndex, currentIndex > 0 else { return }
        let nextPlant = allPlants[currentIndex - 1]
        currentPlant = nextPlant
        viewModel = PlantDetailViewModel(plant: nextPlant)
        Task {
            await viewModel.fetchWikipediaInfo()
        }
    }

    private func moveToNextPlant() {
        guard let currentIndex, currentIndex < allPlants.count - 1 else { return }
        let nextPlant = allPlants[currentIndex + 1]
        currentPlant = nextPlant
        viewModel = PlantDetailViewModel(plant: nextPlant)
        Task {
            await viewModel.fetchWikipediaInfo()
        }
    }

    private var bookView: some View {
        HStack(alignment: .top, spacing: 0) {
            leftColumn
                .frame(maxWidth: .infinity)
                .padding(.leading, 20)
                .padding(.trailing, 8)
                .padding(.vertical, 18)

            rightColumn
                .frame(maxWidth: .infinity)
                .padding(.leading, 12)
                .padding(.trailing, 32)
                .padding(.vertical, 18)
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
            Text(viewModel.japaneseName.isEmpty ? " " : viewModel.japaneseName.hiraganaToKatakana)
                .font(.custom("craftmincho", size: 20))
                .foregroundColor(AppTheme.darkGreen)
                .lineLimit(1)
                .frame(height: 24)
                .opacity(viewModel.japaneseName.isEmpty ? 0 : 1)

            if let uiImage = UIImage(data: currentPlant.imageData) {
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
                    .onTapGesture {
                        showFullScreenImage = true
                    }
            }

            Text(currentPlant.plantName)
                .font(.custom("craftmincho", size: 18))
                .foregroundColor(AppTheme.darkGreen)

            Text(currentPlant.scientificName)
                .font(.custom("craftmincho", size: 12))
                .italic()
                .foregroundColor(.secondary)

            HStack(spacing: 4) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(AppTheme.accentGreen)
                    .font(.system(size: 12))
                Text("信頼度 \(currentPlant.confidence.confidencePercentage)")
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
                         value: currentPlant.locationName.isEmpty ? "不明" : currentPlant.locationName)
            zukanInfoRow(icon: "calendar", label: "発見日",
                         value: currentPlant.date.formatted(date: .long, time: .shortened))

            Divider()
                .padding(.vertical, 4)

            Text("解説")
                .font(.custom("craftmincho", size: 15))
                .foregroundColor(AppTheme.darkGreen)

            ZStack(alignment: .topLeading) {
                // Keep a stable description area height to prevent layout jumps.
                Text(viewModel.isLoading ? "読み込み中..." : viewModel.plantDescription)
                    .font(.custom("craftmincho", size: 11))
                    .foregroundColor(.primary.opacity(0.85))
                    .lineSpacing(3)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
            .frame(height: 180, alignment: .top)
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
                        latitude: currentPlant.latitude,
                        longitude: currentPlant.longitude
                    ),
                    span: MKCoordinateSpan(
                        latitudeDelta: 0.05,
                        longitudeDelta: 0.05
                    )
                )
            ))) {
                Annotation("", coordinate: CLLocationCoordinate2D(
                    latitude: currentPlant.latitude,
                    longitude: currentPlant.longitude
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

struct FullScreenImageView: View {
    let imageData: Data
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            if let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea()
            }

            VStack {
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 16)
                    .padding(.top, 16)

                    Spacer()
                }

                Spacer()
            }
        }
    }
}
