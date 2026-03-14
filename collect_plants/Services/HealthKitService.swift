@preconcurrency import HealthKit
import Combine

class HealthKitService: ObservableObject {
    static let shared = HealthKitService()
    private let healthStore = HKHealthStore()

    @Published var todaySteps: Int = 0

    private init() {}

    // MARK: - Authorization
    func requestAuthorization() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            // シミュレーター用ダミーデータ
            #if targetEnvironment(simulator)
            print("ℹ️ Running on Simulator - HealthKit unavailable, using test data")
            DispatchQueue.main.async {
                self.todaySteps = 12345  // テスト用数値
            }
            return true
            #else
            return false
            #endif
        }

        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let readTypes: Set<HKSampleType> = [stepType]

        do {
            try await healthStore.requestAuthorization(toShare: [], read: readTypes)
            return true
        } catch {
            print("HealthKit authorization error: \(error)")
            return false
        }
    }

    // MARK: - Today Steps
    func fetchTodaySteps() async {
        #if targetEnvironment(simulator)
        // シミュレーター: テスト用ダミーデータ
        DispatchQueue.main.async {
            self.todaySteps = 12345
        }
        return
        #endif

        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: today, end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Step fetch error: \(error?.localizedDescription ?? "Unknown")")
                DispatchQueue.main.async {
                    self.todaySteps = 0
                }
                return
            }
            let steps = Int(sum.doubleValue(for: HKUnit.count()))
            DispatchQueue.main.async {
                self.todaySteps = steps
            }
        }
        healthStore.execute(query)
    }

    // MARK: - Steps for Specific Date
    func fetchStepsForDate(_ date: Date) async -> Int {
        #if targetEnvironment(simulator)
        // シミュレーター: ランダムなテスト値
        return Int.random(in: 5000...15000)
        #endif

        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                guard let result = result, let sum = result.sumQuantity() else {
                    print("Step fetch error for date: \(error?.localizedDescription ?? "Unknown")")
                    continuation.resume(returning: 0)
                    return
                }
                let steps = Int(sum.doubleValue(for: HKUnit.count()))
                continuation.resume(returning: steps)
            }
            healthStore.execute(query)
        }
    }

    // MARK: - Step History (Last 7 days)
    func fetchStepHistory() async -> [(Date, Int)] {
        var history: [(Date, Int)] = []
        let calendar = Calendar.current

        for daysAgo in stride(from: 6, through: 0, by: -1) {
            if let date = calendar.date(byAdding: .day, value: -daysAgo, to: calendar.startOfDay(for: Date())) {
                let steps = await fetchStepsForDate(date)
                history.append((date, steps))
            }
        }

        return history
    }
}
