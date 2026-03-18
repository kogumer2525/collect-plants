import Foundation
import Combine

// MARK: - 動物の種類
enum CritterType: String, CaseIterable {
    case boar
    case badger
    case stag

    /// スプライトストリップのアセット名プレフィックス
    var assetPrefix: String {
        switch self {
        case .boar:   return "boar"
        case .badger: return "critter_badger"
        case .stag:   return "critter_stag"
        }
    }

    /// idle アニメーションのサフィックス
    var idleSuffix: String {
        switch self {
        case .boar:   return "idle_strip"
        case .badger: return "idle"
        case .stag:   return "idle"
        }
    }

    /// walk アニメーションのサフィックス
    var walkSuffix: String {
        switch self {
        case .boar:   return "run_strip"
        case .badger: return "walk"
        case .stag:   return "walk"
        }
    }

    /// 各方向の idle スプライトストリップのフレーム数
    var idleFrameCount: Int {
        switch self {
        case .boar:   return 7
        case .badger: return 28
        case .stag:   return 18
        }
    }

    /// 各方向の walk スプライトストリップのフレーム数
    var walkFrameCount: Int {
        switch self {
        case .boar:   return 4
        case .badger: return 9
        case .stag:   return 8
        }
    }

    /// フレームの高さ（ピクセル）
    var frameHeight: CGFloat {
        switch self {
        case .boar:   return 30
        case .badger: return 32
        case .stag:   return 41
        }
    }

    /// アセット名を生成（方向 + アニメーション種類）
    func assetName(direction: CritterDirection, animation: CritterAnimation) -> String {
        let dirStr = direction.rawValue
        let suffix = animation == .idle ? idleSuffix : walkSuffix
        return "\(assetPrefix)_\(dirStr)_\(suffix)"
    }

    func frameCount(for animation: CritterAnimation) -> Int {
        animation == .idle ? idleFrameCount : walkFrameCount
    }
}

// MARK: - 方向
enum CritterDirection: String, CaseIterable {
    case NE, NW, SE, SW
}

// MARK: - アニメーション
enum CritterAnimation {
    case idle
    case walk
}

// MARK: - 庭にいる動物データ
struct GardenCritter: Identifiable {
    let id: Int
    let type: CritterType
}

class AnimalEventService: ObservableObject {
    static let shared = AnimalEventService()

    @Published var visitingAnimal: String?
    @Published var gardenCritters: [GardenCritter] = []

    private init() {}

    /// 庭レベルに応じて動物を配置する
    /// レベル1上がるごとに動物が1体増える
    func checkForAnimalVisit(plantSpeciesCount: Int, level: Int) {
        let animalCount = max(0, level - 1)

        var rng = SeededRandomNumberGenerator(seed: UInt64(Date().timeIntervalSince1970))
        let allTypes = CritterType.allCases

        var critters: [GardenCritter] = []
        for i in 0..<animalCount {
            let typeIndex = Int(rng.next() % UInt64(allTypes.count))
            critters.append(GardenCritter(id: i, type: allTypes[typeIndex]))
        }

        gardenCritters = critters

        if !critters.isEmpty {
            visitingAnimal = nil
        }
    }
}
