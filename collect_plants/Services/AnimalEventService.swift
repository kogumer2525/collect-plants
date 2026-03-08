import Foundation
import Combine

class AnimalEventService: ObservableObject {
    static let shared = AnimalEventService()

    @Published var visitingAnimal: String?

    private init() {}

    // TODO: 動物来訪イベント - 後で実装
    func checkForAnimalVisit(plantSpeciesCount: Int) {
        // 後で実装
    }
}
