import MapKit
import Combine

@Observable
class MapViewModel {
    var plants: [PlantRecord] = []
    var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    // Health Kit & Points
    @ObservationIgnored private let healthKitService = HealthKitService.shared
    @ObservationIgnored private let pointManager = PointManager.shared
    @ObservationIgnored private let coreDataService = CoreDataService.shared
    @ObservationIgnored private let locationService = LocationService.shared

    var todaySteps: Int = 0
    var todayPoints: Int = 0
    var totalPoints: Int = 0
    var stepHistory: [(Date, Int)] = []

    func loadPlants() {
        let allPlants = coreDataService.fetchAllPlants()
        // 位置情報が「不明」（座標 (0, 0)）のレコードを除外
        plants = allPlants.filter { !($0.latitude == 0.0 && $0.longitude == 0.0) }
        if let location = locationService.currentLocation {
            region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }

    // MARK: - Health Kit & Points
    func requestHealthKitAuthorization() async {
        let authorized = await healthKitService.requestAuthorization()
        if authorized {
            await refreshTodaySteps()
        }
    }

    func refreshTodaySteps() async {
        await healthKitService.fetchTodaySteps()
        
        DispatchQueue.main.async {
            self.todaySteps = self.healthKitService.todaySteps
            self.claimTodayPoints()
            self.totalPoints = self.pointManager.getTotalPoints()
        }
    }

    func loadStepHistory() async {
        let history = await healthKitService.fetchStepHistory()
        DispatchQueue.main.async {
            self.stepHistory = history
        }
    }

    // MARK: - Capture Historical Steps
    /// 前回計算日以降の全日分について、歩数をポイント化
    func captureHistoricalSteps() async {
        let lastCalculatedDate = pointManager.getLastCalculatedDate() ?? Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: 1, to: lastCalculatedDate) ?? Date()
        
        // startDate から今日まで、各日の歩数を取得してポイント化
        var currentDate = startDate
        while calendar.compare(currentDate, to: Date(), toGranularity: .day) != .orderedDescending {
            let steps = await healthKitService.fetchStepsForDate(currentDate)
            if steps > 0 {
                let _ = pointManager.claimPointsForSteps(steps, for: currentDate)
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        // 最後の計算日を今日に更新
        pointManager.setLastCalculatedDate(Date())
        
        // UI を更新
        DispatchQueue.main.async {
            self.totalPoints = self.pointManager.getTotalPoints()
        }
    }

    private func claimTodayPoints() {
        _ = pointManager.claimPointsForSteps(todaySteps)
        todayPoints = pointManager.getDailyClaimedPoints()
        totalPoints = pointManager.getTotalPoints()
    }

    // MARK: - Format Helpers
    func formatSteps(_ steps: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: steps)) ?? "\(steps)"
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
}
