@preconcurrency import CoreLocation
import Combine
import MapKit

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationService()
    private let manager = CLLocationManager()

    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    private var locationContinuation: CheckedContinuation<CLLocation, Error>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func getCurrentLocation() async throws -> CLLocation {
        requestPermission()
        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            manager.requestLocation()
        }
    }

    func reverseGeocode(location: CLLocation) async throws -> String {
        guard let request = MKReverseGeocodingRequest(location: location) else {
            return "不明な場所"
        }
        let mapItems = try await request.mapItems
        guard let address = mapItems.first?.address else {
            return "不明な場所"
        }
        return address.shortAddress ?? address.fullAddress
    }

    // MARK: - CLLocationManagerDelegate

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.currentLocation = location
            self.locationContinuation?.resume(returning: location)
            self.locationContinuation = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.locationContinuation?.resume(throwing: error)
            self.locationContinuation = nil
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
        }
    }
}
