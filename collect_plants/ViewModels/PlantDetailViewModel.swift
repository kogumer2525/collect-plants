import Foundation

@MainActor
@Observable
class PlantDetailViewModel {
    let plant: PlantRecord
    var japaneseName: String = ""
    var plantDescription: String = ""
    var isLoading = false

    init(plant: PlantRecord) {
        self.plant = plant
    }

    func loadPlantInfo() {
        // CoreDataから直接読み込み（キャッシュされているため）
        japaneseName = plant.japaneseName
        plantDescription = plant.plantDescription
        
        // 古いデータで description が空の場合、フォールバック
        if plantDescription.isEmpty && japaneseName != "日本語名不明" && !japaneseName.isEmpty {
            japaneseName = plant.japaneseName.isEmpty ? "不明" : plant.japaneseName
            plantDescription = "情報が登録されていません"
        }
    }
}
