import Foundation

enum SortOption {
    case japaneseNameAscending
    case englishNameAscending
    case dateNewest
    case locationAscending
    
    var label: String {
        switch self {
        case .japaneseNameAscending: return "日本語名（昇順）"
        case .englishNameAscending: return "英名（昇順）"
        case .dateNewest: return "撮った日付順"
        case .locationAscending: return "撮影場所（昇順）"
        }
    }
}

@Observable
class DictionaryViewModel {
    var plants: [PlantRecord] = []
    var sortOption: SortOption = .dateNewest

    private let coreDataService = CoreDataService.shared

    func loadPlants() {
        plants = coreDataService.fetchAllPlants()
    }

    var uniquePlants: [PlantRecord] {
        var seen = Set<String>()
        let filtered = plants.filter { plant in
            let key = plant.plantName
            if seen.contains(key) { return false }
            seen.insert(key)
            return true
        }
        
        // 並び替え処理
        switch sortOption {
        case .japaneseNameAscending:
            return filtered.sorted { ($0.japaneseName.isEmpty ? $0.plantName : $0.japaneseName) < ($1.japaneseName.isEmpty ? $1.plantName : $1.japaneseName) }
        case .englishNameAscending:
            return filtered.sorted { $0.plantName < $1.plantName }
        case .dateNewest:
            return filtered.sorted { $0.date > $1.date }
        case .locationAscending:
            return filtered.sorted { $0.locationName < $1.locationName }
        }
    }
}
