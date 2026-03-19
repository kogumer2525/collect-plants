import MapKit
import SwiftUI

struct PlantMapView: View {
    @State private var viewModel = MapViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                // Full Screen Map
                Map(initialPosition: .region(viewModel.region)) {
                    ForEach(viewModel.plants) { plant in
                        Annotation(
                            plant.japaneseName.isEmpty ? plant.plantName : plant.japaneseName,
                            coordinate: CLLocationCoordinate2D(
                                latitude: plant.latitude,
                                longitude: plant.longitude
                            )
                        ) {
                            NavigationLink(
                                destination: PlantDetailView(
                                    plant: plant, allPlants: viewModel.plants)
                            ) {
                                VStack(spacing: 2) {
                                    ZStack {
                                        Circle()
                                            .fill(AppTheme.primaryGradient)
                                            .frame(width: 36, height: 36)
                                            .shadow(
                                                color: AppTheme.accentGreen.opacity(0.4), radius: 4,
                                                x: 0, y: 2)
                                        Image(systemName: "leaf.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(.white)
                                    }
                                    Text(
                                        plant.japaneseName.isEmpty
                                            ? plant.plantName : plant.japaneseName
                                    )
                                    .font(.caption2.bold())
                                    .foregroundColor(AppTheme.darkGreen)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(AppTheme.cardBackground.opacity(0.95))
                                            .shadow(
                                                color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                    )
                                }
                            }
                        }
                    }
                }
                .ignoresSafeArea(edges: .bottom)

                // Floating Action Button (Bottom Right)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(destination: StepsDetailView()) {
                            VStack(spacing: 6) {
                                Image(systemName: "figure.walk")
                                    .font(.system(size: 24, weight: .semibold))
                                Text("歩数")
                                    .font(.subheadline.bold())
                            }
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(AppTheme.darkGreen)
                            .clipShape(Circle())
                            .shadow(color: AppTheme.darkGreen.opacity(0.5), radius: 12, x: 0, y: 6)
                        }
                        .padding(24)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("マップ")
                        .font(.headline)
                        .foregroundColor(AppTheme.darkGreen)
                }
            }
            .toolbarBackground(AppTheme.cardBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                viewModel.loadPlants()
                Task {
                    await viewModel.requestHealthKitAuthorization()
                    await viewModel.loadStepHistory()
                }
            }
        }
    }
}
