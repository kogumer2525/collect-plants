import SwiftUI
import MapKit

struct PlantMapView: View {
    @State private var viewModel = MapViewModel()

    var body: some View {
        NavigationStack {
            Map(initialPosition: .region(viewModel.region)) {
                ForEach(viewModel.plants) { plant in
                    Annotation(plant.plantName, coordinate: CLLocationCoordinate2D(
                        latitude: plant.latitude,
                        longitude: plant.longitude
                    )) {
                        VStack(spacing: 2) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.primaryGradient)
                                    .frame(width: 36, height: 36)
                                    .shadow(color: AppTheme.accentGreen.opacity(0.4), radius: 4, x: 0, y: 2)
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                            }
                            Text(plant.plantName)
                                .font(.caption2.bold())
                                .foregroundColor(AppTheme.darkGreen)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(AppTheme.cardBackground.opacity(0.95))
                                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                )
                        }
                    }
                }
            }
            .navigationTitle("マップ")
            .toolbarBackground(AppTheme.cardBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                viewModel.loadPlants()
            }
        }
    }
}
