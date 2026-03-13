import Foundation

@MainActor
@Observable
class PlantDetailViewModel {
    let plant: PlantRecord
    var japaneseName: String = ""
    var plantDescription: String = ""
    var isLoading = false

    private let wikipediaService = WikipediaService.shared

    init(plant: PlantRecord) {
        self.plant = plant
    }

    func fetchWikipediaInfo() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let info = try await wikipediaService.fetchPlantInfo(scientificName: plant.scientificName)
            japaneseName = info.japaneseName
            plantDescription = info.description
        } catch {
            japaneseName = "不明"
            plantDescription = "情報を取得できませんでした"
        }
    }
}
