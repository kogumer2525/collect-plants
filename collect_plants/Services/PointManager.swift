import Foundation

class PointManager {
    static let shared = PointManager()

    private let userDefaults = UserDefaults.standard

    // Keys
    private let totalPointsKey = "totalPoints"
    private let dailyClaimedPointsKey = "dailyClaimedPoints"
    private let dailyClaimedDateKey = "dailyClaimedDate"

    private init() {}

    // MARK: - Total Points
    func getTotalPoints() -> Int {
        userDefaults.integer(forKey: totalPointsKey)
    }

    func addPoints(_ points: Int) {
        let current = getTotalPoints()
        userDefaults.set(current + points, forKey: totalPointsKey)
    }

    // MARK: - Consume Points
    func consumePoints(_ points: Int) -> Bool {
        let current = getTotalPoints()
        if current >= points {
            userDefaults.set(current - points, forKey: totalPointsKey)
            return true
        }
        return false
    }

    // MARK: - Daily Claimed Points (per date)
    func getDailyClaimedPoints(for date: Date = Date()) -> Int {
        let dateString = dateToString(date)
        let key = "\(dailyClaimedPointsKey)_\(dateString)"
        return userDefaults.integer(forKey: key)
    }

    func setDailyClaimedPoints(_ points: Int, for date: Date = Date()) {
        let dateString = dateToString(date)
        let key = "\(dailyClaimedPointsKey)_\(dateString)"
        userDefaults.set(points, forKey: key)
    }

    // MARK: - Points Claim (差分計算)
    /// 歩数からポイントを計算・付与し、増加分を返す
    /// - Parameters:
    ///   - totalSteps: その日の累計歩数
    ///   - date: 対象日付（デフォルトは今日）
    /// - Returns: 今回付与されたポイント数（0の場合もある）
    func claimPointsForSteps(_ totalSteps: Int, for date: Date = Date()) -> Int {
        let newTotalPoints = totalSteps / 100  // 100歩 = 1ポイント（切り捨て）
        let currentClaimed = getDailyClaimedPoints(for: date)
        let pointsToAdd = max(0, newTotalPoints - currentClaimed)

        if pointsToAdd > 0 {
            addPoints(pointsToAdd)
            setDailyClaimedPoints(newTotalPoints, for: date)
        }

        return pointsToAdd
    }

    // MARK: - Today Steps Check
    func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }

    // MARK: - Last Calculated Date
    func getLastCalculatedDate() -> Date? {
        let timestamp = userDefaults.double(forKey: "lastCalculatedDate")
        return timestamp > 0 ? Date(timeIntervalSince1970: timestamp) : nil
    }

    func setLastCalculatedDate(_ date: Date) {
        userDefaults.set(date.timeIntervalSince1970, forKey: "lastCalculatedDate")
    }

    // MARK: - Date Helper
    private func dateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    func stringToDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }

    // MARK: - Reset (for testing)
    func reset() {
        userDefaults.removeObject(forKey: totalPointsKey)
        userDefaults.dictionaryRepresentation().keys
            .filter { $0.hasPrefix(dailyClaimedPointsKey) }
            .forEach { userDefaults.removeObject(forKey: $0) }
    }
}
