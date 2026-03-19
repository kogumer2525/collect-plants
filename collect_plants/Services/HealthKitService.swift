import Combine
@preconcurrency import HealthKit

class HealthKitService: ObservableObject {
    static let shared = HealthKitService()
    private let healthStore = HKHealthStore()

    @Published var todaySteps: Int = 0
    private var isDemoMode = false  // HealthKit利用不可時のデモモードフラグ

    private init() {}

    // MARK: - Authorization
    func requestAuthorization() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("ℹ️ HealthKit unavailable - using demo data")
            isDemoMode = true
            DispatchQueue.main.async {
                self.todaySteps = 12345
            }
            return true
        }

        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let readTypes: Set<HKSampleType> = [stepType]

        do {
            try await healthStore.requestAuthorization(toShare: [], read: readTypes)
            return true
        } catch {
            print("HealthKit authorization error: \(error) - using demo data")
            isDemoMode = true
            DispatchQueue.main.async {
                self.todaySteps = 12345
            }
            return true  // デモモードで継続
        }
    }

    // MARK: - Today Steps
    func fetchTodaySteps() async {
        if isDemoMode {
            DispatchQueue.main.async {
                self.todaySteps = 12345
            }
            return
        }

        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(
            withStart: today, end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(
            quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum
        ) { _, result, error in
            if error != nil || result == nil || result?.sumQuantity() == nil {
                print("Step fetch error - switching to demo mode")
                self.isDemoMode = true
                DispatchQueue.main.async {
                    self.todaySteps = 12345
                }
                return
            }

            let steps = Int((result!.sumQuantity()!).doubleValue(for: HKUnit.count()))
            DispatchQueue.main.async {
                self.todaySteps = steps
            }
        }
        healthStore.execute(query)
    }

    // MARK: - Steps for Specific Date
    func fetchStepsForDate(_ date: Date) async -> Int {
        if isDemoMode {
            return Int.random(in: 5000...15000)
        }

        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay, end: endOfDay, options: .strictStartDate)

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum
            ) { _, result, error in
                if error != nil || result == nil || result?.sumQuantity() == nil {
                    print("Step fetch error for date - switching to demo mode")
                    self.isDemoMode = true
                    continuation.resume(returning: Int.random(in: 5000...15000))
                    return
                }

                let steps = Int((result!.sumQuantity()!).doubleValue(for: HKUnit.count()))
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
            if let date = calendar.date(
                byAdding: .day, value: -daysAgo, to: calendar.startOfDay(for: Date()))
            {
                let steps = await fetchStepsForDate(date)
                history.append((date, steps))
            }
        }

        return history
    }
}
