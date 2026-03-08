import MapKit

@Observable
class MapViewModel {
    var plants: [PlantRecord] = []
    var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    private let coreDataService = CoreDataService.shared
    private let locationService = LocationService.shared

    func loadPlants() {
        plants = coreDataService.fetchAllPlants()
        if let location = locationService.currentLocation {
            region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
}
