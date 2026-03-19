import Foundation
import Combine

// MARK: - 動物の種類
enum CritterType: String, CaseIterable {
    case boar
    case stag
    case wolf

    /// ローテーション順序: Lv.2→boar, Lv.3→stag, Lv.4→wolf, Lv.5→boar...
    static let rotationOrder: [CritterType] = [.boar, .stag, .wolf]

    /// レベルから追加される動物リストを返す
    static func crittersForLevel(_ level: Int) -> [CritterType] {
        let count = max(0, level - 1)
        return (0..<count).map { i in
            rotationOrder[i % rotationOrder.count]
        }
    }
}

// MARK: - スプライト形式
enum SpriteFormat {
    /// 横1列のストリップ画像（boar, stag）
    case strip
    /// グリッド形式のスプライトシート（wolf）
    case sheet(columns: Int, rows: Int)
}

// MARK: - 方向
enum CritterDirection: String, CaseIterable {
    case NE, NW, SE, SW

    /// wolf スプライトシートでの行インデックス
    var wolfRow: Int {
        switch self {
        case .NW: return 0
        case .NE: return 1
        case .SW: return 2
        case .SE: return 3
        }
    }
}

// MARK: - アニメーション
enum CritterAnimation {
    case idle
    case walk
}

// MARK: - スプライト情報
extension CritterType {
    var assetPrefix: String {
        switch self {
        case .boar: return "boar"
        case .stag: return "critter_stag"
        case .wolf: return "wolf"
        }
    }

    var spriteFormat: SpriteFormat {
        switch self {
        case .boar, .stag: return .strip
        case .wolf:        return .sheet(columns: 4, rows: 4) // idle: 4x4, run: 8x4
        }
    }

    /// ストリップ形式のアセット名（boar, stag 用）
    func stripAssetName(direction: CritterDirection, animation: CritterAnimation) -> String {
        let dirStr = direction.rawValue
        let suffix: String
        switch (self, animation) {
        case (.boar, .idle):  suffix = "idle_strip"
        case (.boar, .walk):  suffix = "run_strip"
        case (.stag, .idle):  suffix = "idle"
        case (.stag, .walk):  suffix = "walk"
        default:              suffix = "idle"
        }
        return "\(assetPrefix)_\(dirStr)_\(suffix)"
    }

    /// スプライトシート形式のアセット名（wolf 用）
    func sheetAssetName(animation: CritterAnimation) -> String {
        switch animation {
        case .idle: return "wolf_idle"
        case .walk: return "wolf_run"
        }
    }

    /// フレーム数
    func frameCount(for animation: CritterAnimation) -> Int {
        switch self {
        case .boar:
            return animation == .idle ? 7 : 4
        case .stag:
            return animation == .idle ? 24 : 11
        case .wolf:
            return animation == .idle ? 4 : 8
        }
    }

    /// シート形式の列数（wolf 用）
    func sheetColumns(for animation: CritterAnimation) -> Int {
        switch animation {
        case .idle: return 4
        case .walk: return 8
        }
    }

    /// フレームの高さ（ストリップ形式用）
    var frameHeight: CGFloat {
        switch self {
        case .boar:  return 30
        case .stag:  return 41
        case .wolf:  return 64
        }
    }

    /// 表示倍率（動物間のサイズバランス調整）
    var displayScale: CGFloat {
        switch self {
        case .boar:  return 1.0
        case .stag:  return 1.0
        case .wolf:  return 1.8
        }
    }
}

// MARK: - 庭にいる動物データ
struct GardenCritter: Identifiable {
    let id: Int
    let type: CritterType
}

class AnimalEventService: ObservableObject {
    static let shared = AnimalEventService()

    @Published var gardenCritters: [GardenCritter] = []

    private init() {}

    /// 庭レベルに応じて動物を配置する
    /// Lv.2→boar, Lv.3→stag, Lv.4→wolf, Lv.5→boar... のローテーション
    func updateCritters(level: Int) {
        let types = CritterType.crittersForLevel(level)
        gardenCritters = types.enumerated().map { index, type in
            GardenCritter(id: index, type: type)
        }
    }
}
