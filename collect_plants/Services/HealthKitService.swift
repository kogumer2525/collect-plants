@preconcurrency import HealthKit
import Combine

class HealthKitService: ObservableObject {
    static let shared = HealthKitService()
    private let healthStore = HKHealthStore()

    @Published var stepCount: Int = 0

    private init() {}

    // TODO: 歩数ポイント機能 - 後で実装
    func requestAuthorization() async {
        // 後で実装
    }

    func fetchSteps() async {
        // 後で実装
    }
}
