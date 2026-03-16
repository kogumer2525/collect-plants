import SwiftUI

// MARK: - タイル種類（PNG タイルセット対応）
enum TileType: Equatable {
    case dirt
    case dirtEdgeL
    case dirtEdgeR
    case dirtRough
    case grassLight
    case grassMedium
    case grassDense
    case grassLush
    case grassBush
    case grassFlower
    case path
    case pathEdge
    case stonePath
    case water
    case waterEdge

    var assetName: String {
        switch self {
        case .dirt:         return "tile_000"
        case .dirtEdgeL:    return "tile_004"
        case .dirtEdgeR:    return "tile_005"
        case .dirtRough:    return "tile_012"
        case .grassLight:   return "tile_022"
        case .grassMedium:  return "tile_024"
        case .grassDense:   return "tile_027"
        case .grassLush:    return "tile_040"
        case .grassBush:    return "tile_033"
        case .grassFlower:  return "tile_037"
        case .path:         return "tile_007"
        case .pathEdge:     return "tile_016"
        case .stonePath:    return "tile_061"
        case .water:        return "tile_095"
        case .waterEdge:    return "tile_069"
        }
    }

    /// 花が生えるタイル（grassLight, grassMedium, grassDense, grassLush のみ）
    var canPlacePlant: Bool {
        switch self {
        case .grassLight, .grassMedium, .grassDense, .grassLush:
            return true
        default:
            return false
        }
    }

    /// 家具を置けるタイル
    var canPlaceFurniture: Bool {
        switch self {
        case .grassLight, .grassMedium, .grassDense, .grassLush:
            return true
        default:
            return false
        }
    }

    /// 動物が出現するタイル（dirt のみ）
    var canSpawnAnimal: Bool {
        switch self {
        case .dirt, .dirtRough, .dirtEdgeL, .dirtEdgeR:
            return true
        default:
            return false
        }
    }
}

// MARK: - デコレーション
enum TileDecoration: Equatable {
    case none
    case flowerRed
    case flowerPurple
    case bush
    case tallGrass
    case log
    case stump
    case rockSmall
    case rockLarge

    var assetName: String? {
        switch self {
        case .none:         return nil
        case .flowerRed:    return "tile_041"
        case .flowerPurple: return "tile_044"
        case .bush:         return "tile_045"
        case .tallGrass:    return "tile_043"
        case .log:          return "tile_048"
        case .stump:        return "tile_051"
        case .rockSmall:    return "tile_062"
        case .rockLarge:    return "tile_053"
        }
    }
}

// MARK: - 庭レイアウト定義
// スタッガードグリッド: 偶数行は cols 個、奇数行は cols-1 個（半タイルずらし）
// 菱形タイルを長方形に隙間なく敷き詰める配置
//
// タイル配置図（偶数行: 0始まり、奇数行: 0.5始まり）:
//   row0: [0] [1] [2] [3] [4] [5] [6]
//   row1:  [0] [1] [2] [3] [4] [5]
//   row2: [0] [1] [2] [3] [4] [5] [6]
//   ...
//
// 画面幅 = cols * tileW （tileW = ダイヤの横幅）
// 行間  = tileH / 2     （tileH = ダイヤの縦幅 = tileW / 2）

private let D  = TileType.dirt
private let GL = TileType.grassLight
private let GM = TileType.grassMedium
private let GD = TileType.grassDense
private let GU = TileType.grassLush
private let GB = TileType.grassBush
private let GF = TileType.grassFlower
private let P  = TileType.path
private let PE = TileType.pathEdge
private let SP = TileType.stonePath
private let W  = TileType.water
private let WE = TileType.waterEdge
private let DR = TileType.dirtRough

// 偶数行: 10列（左右に見切れ用の茂みを1列追加）
// 奇数行: 9列（同上）
// 偶数行は半タイル左にずらして描画 → 奇数行と噛み合い、左右端がまっすぐになる
let gardenCols = 10  // 偶数行のタイル数
// 奇数行のタイル数 = gardenCols - 1 = 9

// ※左端[0]と右端[9or8]は左右見切れ用の茂み
// 上下にも茂み行を多めに入れて見切れに備える
// 内側は基本GL(草)で、col 4,5 / row 中央付近に2マス幅の土(D)十字道を通す
// アクセントに水・石畳を少し配置
let gardenLayoutMap: [[TileType]] = [
    // ===== 上端: 茂み多め（見切れ前提） =====
    [GB, GB, GB, GB, GB, GB, GB, GB, GB, GB],  // row 0
     [GB, GB, GB, GB, GB, GB, GB, GB, GB],     // row 1
    [GB, GB, GB, GB, GB, GB, GB, GB, GB, GB],  // row 2
     [GB, GB, GB, GB, GB, GB, GB, GB, GB],     // row 3
    [GB, GB, GB, GB, GB, GB, GB, GB, GB, GB],  // row 4
     [GB, GB, GB, GB, GB, GB, GB, GB, GB],     // row 5
    [GB, GB, GB, GB, GB, GB, GB, GB, GB, GB],  // row 6
     [GB, GB, GB, GB, GB, GB, GB, GB, GB],     // row 7
    [GB, GB, GB, GB, GB, GB, GB, GB, GB, GB],  // row 8
    // ===== 茂み→草遷移 =====
     [GB, GD, GD, GD, GD, GD, GD, GD, GB],     // row 9
    [GB, GD, GM, GM, GM, GM, GM, GM, GD, GB],  // row 10
     [GB, GM, GM, GL, GL, GL, GL, GM, GB],     // row 11
    [GB, GM, GL, GL, GL, GL, GL, GL, GM, GB],  // row 12
    // ===== 草原 + X字斜め道（端から端まで）=====
    // ＼道: row13(col6,7)→row24(col1,2)  ／道: row13(col1,2)→row24(col7,8)
    // 下半分は対称に折り返し
     [GB, D,  D,  GL, GL, GL, D,  D,  GB],     // row 13
    [GB, GL, D,  D,  GL, GL, D,  D,  GL, GB],  // row 14
     [GB, GL, D,  D,  GL, D,  D,  GL, GB],     // row 15
    [GB, GL, GL, D,  D,  D,  D,  GL, GL, GB],  // row 16
     [GB, GL, GL, D,  D,  D,  GL, GL, GB],     // row 17
    // ===== 中心交差 =====
    [GB, GL, GL, GL, SP, SP, GL, GL, GL, GB],  // row 18  石畳
     [GB, GL, GL, D,  SP, D,  GL, GL, GB],     // row 19  石畳
    // ===== 下半分 X字 =====
    [GB, GL, GL, D,  D,  D,  D,  GL, GL, GB],  // row 20
     [GB, GL, D,  D,  GL, D,  D,  GL, GB],     // row 21
    [GB, GL, D,  D,  GL, GL, D,  D,  GL, GB],  // row 22
     [GB, D,  D,  GL, GL, GL, D,  D,  GB],     // row 23
    [GB, D,  D,  GL, GL, GL, D,  D,  D,  GB],  // row 24
     [GB, D,  D,  GL, GL, D,  D,  GL, GB],     // row 25
    [GB, GL, D,  D,  GL, D,  D,  GL, GL, GB],  // row 26
     [GB, GL, D,  D,  D,  D,  GL, GL, GB],     // row 27
    [GB, GL, GL, D,  D,  D,  GL, GL, GL, GB],  // row 28
     [GB, GL, GL, D,  D,  GL, GL, GL, GB],     // row 29
    [GB, GL, GL, D,  D,  D,  GL, GL, GL, GB],  // row 30
     [GB, GL, D,  D,  D,  D,  GL, GL, GB],     // row 31
    [GB, GL, D,  D,  GL, D,  D,  GL, GL, GB],  // row 32
     [GB, D,  D,  GL, GL, D,  D,  GL, GB],     // row 33
    [GB, D,  D,  GL, GL, GL, D,  D,  GL, GB],  // row 34
     [GB, D,  GL, GL, GL, GL, D,  D,  GB],     // row 35
    // ===== 草原 + 水辺（塊で配置）=====
    [GB, GL, GL, GL, GL, GL, WE, WE, GL, GB],  // row 36  水辺（右寄り）
     [GB, GL, GL, GL, GL, WE, W,  W,  GB],     // row 37
    [GB, GL, GL, GL, GL, WE, W,  WE, GL, GB],  // row 38
     [GB, GL, GL, GL, GL, GL, WE, GL, GB],     // row 39
    [GB, GL, WE, WE, GL, GL, GL, GL, GL, GB],  // row 40  水辺（左寄り）
     [GB, WE, W,  WE, GL, GL, GL, GL, GB],     // row 41
    [GB, GL, WE, GL, GL, GL, GL, GL, GL, GB],  // row 42
     [GB, GL, GL, GL, GL, GL, GL, GL, GB],     // row 43
    // ===== 草→茂み遷移 =====
    [GB, GM, GL, GL, GL, GL, GL, GL, GM, GB],  // row 44
     [GB, GD, GM, GL, GL, GL, GM, GD, GB],     // row 45
    [GB, GD, GM, GM, GM, GM, GM, GM, GD, GB],  // row 46
     [GB, GB, GD, GD, GD, GD, GD, GB, GB],     // row 47
    [GB, GB, GB, GB, GB, GB, GB, GB, GB, GB],  // row 48
    // ===== 下端: 茂み多め（見切れ前提） =====
     [GB, GB, GB, GB, GB, GB, GB, GB, GB],     // row 49
    [GB, GB, GB, GB, GB, GB, GB, GB, GB, GB],  // row 50
     [GB, GB, GB, GB, GB, GB, GB, GB, GB],     // row 51
    [GB, GB, GB, GB, GB, GB, GB, GB, GB, GB],  // row 52
     [GB, GB, GB, GB, GB, GB, GB, GB, GB],     // row 53
    [GB, GB, GB, GB, GB, GB, GB, GB, GB, GB],  // row 54
     [GB, GB, GB, GB, GB, GB, GB, GB, GB],     // row 55
]

let gardenRows = gardenLayoutMap.count

let gardenDecorationMap: [[TileDecoration]] = {
    let __ = TileDecoration.none
    let FR = TileDecoration.flowerRed
    let FP = TileDecoration.flowerPurple
    let BU = TileDecoration.bush
    let TG = TileDecoration.tallGrass
    let RS = TileDecoration.rockSmall
    let ST = TileDecoration.stump
    return [
        // row 0-8: 茂み
        [BU, BU, BU, BU, BU, BU, BU, BU, BU, BU],
         [BU, BU, BU, BU, BU, BU, BU, BU, BU],
        [BU, BU, BU, BU, BU, BU, BU, BU, BU, BU],
         [BU, BU, BU, BU, BU, BU, BU, BU, BU],
        [BU, BU, BU, BU, BU, BU, BU, BU, BU, BU],
         [BU, BU, BU, BU, BU, BU, BU, BU, BU],
        [BU, BU, BU, BU, BU, BU, BU, BU, BU, BU],
         [BU, BU, BU, BU, BU, BU, BU, BU, BU],
        [BU, BU, BU, BU, BU, BU, BU, BU, BU, BU],
        // row 9-12: 遷移
         [BU, TG, TG, __, __, __, __, TG, BU],
        [BU, TG, __, __, __, __, __, __, TG, BU],
         [BU, __, __, __, __, __, __, __, BU],
        [BU, __, __, __, __, __, __, __, __, BU],
        // row 13-23: 草原+道
         [__, __, __, __, __, __, __, __, __],
        [__, __, __, __, __, __, __, __, __, __],
         [__, __, __, __, __, __, __, __, __],
        [__, __, __, __, __, __, __, __, __, __],
         [__, __, __, __, __, __, __, __, __],
        [__, __, __, __, __, __, __, __, __, __],
         [__, __, __, __, __, __, __, __, __],
        [__, __, __, __, __, __, __, __, __, __],
         [__, __, __, __, __, __, __, __, __],
        [__, __, __, __, __, __, __, __, __, __],
         [__, __, __, __, __, __, __, __, __],
        // row 24-27: 中心広場
        [__, __, __, __, __, RS, __, __, __, __],
         [__, __, __, __, __, __, __, __, __],
        [__, __, __, __, __, __, __, __, __, __],
         [__, __, __, __, __, __, __, __, __],
        // row 28-37: 草原+道
        [__, __, __, __, __, __, __, __, __, __],
         [__, __, __, __, __, __, __, __, __],
        [__, __, __, __, __, __, __, __, __, __],
         [__, __, __, __, __, __, __, __, __],
        [__, __, __, __, __, __, __, __, __, __],
         [__, __, __, __, __, __, __, __, __],
        [__, __, __, __, __, __, __, __, __, __],
         [__, __, __, __, __, __, __, ST, __],
        [__, __, __, __, __, __, __, __, __, __],
         [__, __, __, __, __, __, __, __, __],
        // row 38-43: 草原+水辺
        [__, __, __, __, __, __, __, __, __, __],
         [__, __, __, __, __, __, __, __, __],
        [__, __, __, __, __, __, __, __, __, __],
         [__, __, __, __, __, __, __, __, __],
        [__, __, __, __, __, __, __, __, __, __],
         [__, __, __, __, __, __, __, __, __],
        // row 44-48: 遷移
        [__, __, __, __, __, __, __, __, __, __],
         [__, TG, __, __, __, __, __, TG, __],
        [BU, TG, __, __, __, __, __, __, TG, BU],
         [BU, BU, TG, __, __, __, TG, BU, BU],
        [BU, BU, BU, BU, BU, BU, BU, BU, BU, BU],
        // row 49-55: 茂み
         [BU, BU, BU, BU, BU, BU, BU, BU, BU],
        [BU, BU, BU, BU, BU, BU, BU, BU, BU, BU],
         [BU, BU, BU, BU, BU, BU, BU, BU, BU],
        [BU, BU, BU, BU, BU, BU, BU, BU, BU, BU],
         [BU, BU, BU, BU, BU, BU, BU, BU, BU],
        [BU, BU, BU, BU, BU, BU, BU, BU, BU, BU],
         [BU, BU, BU, BU, BU, BU, BU, BU, BU],
    ]
}()

// MARK: - 描画アイテム
private struct TileItem: Identifiable {
    let id: Int
    let col: Int
    let row: Int
    let type: TileType
    let decoration: TileDecoration
    let isMain: Bool
}

// MARK: - 庭グリッドビュー（スタッガードグリッド配置）
struct GardenGridView: View {
    let plantCount: Int
    let ownedFurnitureIDs: Set<String>
    let critters: [GardenCritter]

    private let cols = gardenCols
    private let rows = gardenRows

    private let flowerDecoAssets = [
        "tile_041", "tile_044", "tile_042", "tile_046", "tile_041",
        "tile_044", "tile_042", "tile_046", "tile_041", "tile_044"
    ]

    var body: some View {
        GeometryReader { geo in
            let screenW = geo.size.width
            let screenH = geo.size.height

            // ダイヤタイルの寸法
            // 奇数行(9タイル)が画面幅にフィット: 画面幅 = 9 * tileW
            // 偶数行(10タイル)は半タイル左にはみ出す → 左右1列が見切れ用
            let tileW = screenW / CGFloat(cols - 1)
            let tileH = tileW / 2
            let rowStep = tileH / 2

            let tileImgSize = tileW

            // グリッド全体の高さ
            let gridHeight = CGFloat(rows - 1) * rowStep + tileH
            let offsetY = (screenH - gridHeight) / 2

            let plants = plantGrid
            let dirtPositions = dirtTilePositions(tileW: tileW, tileH: tileH, rowStep: rowStep, offsetY: offsetY)

            ZStack(alignment: .topLeading) {
                // 地面・デコレーション・花レイヤー
                ForEach(0..<rows, id: \.self) { row in
                    let isOdd = row % 2 == 1
                    let colCount = isOdd ? cols - 1 : cols
                    let xOffset: CGFloat = isOdd ? 0 : -tileW / 2

                    ForEach(0..<colCount, id: \.self) { col in
                        let x = xOffset + CGFloat(col) * tileW + tileW / 2
                        let y = offsetY + CGFloat(row) * rowStep + tileH / 2

                        let tileType = gardenLayoutMap[row][col]
                        let deco = gardenDecorationMap[row][col]
                        let key = row * cols + col

                        // 地面タイル
                        tileImage(name: tileType.assetName, size: tileImgSize)
                            .position(x: x, y: y)

                        // 固定デコレーション
                        if let decoAsset = deco.assetName {
                            decoImage(name: decoAsset, tileSize: tileImgSize)
                                .position(x: x, y: y - tileH * 0.25)
                        }

                        // 植物（図鑑登録で増える花）
                        if let flowerAsset = plants[key] {
                            decoImage(name: flowerAsset, tileSize: tileImgSize)
                                .position(x: x, y: y - tileH * 0.25)
                        }
                    }
                }

                // 動物レイヤー（タイルの上に描画）
                ForEach(critters) { critter in
                    CritterView(
                        critter: critter,
                        dirtTilePositions: dirtPositions,
                        tileSize: tileImgSize
                    )
                }
            }
            .frame(width: screenW, height: screenH)
            .clipped()
        }
    }

    /// dirtタイルの画面座標一覧（動物の移動先候補）
    private func dirtTilePositions(tileW: CGFloat, tileH: CGFloat, rowStep: CGFloat, offsetY: CGFloat) -> [(x: CGFloat, y: CGFloat)] {
        var positions: [(x: CGFloat, y: CGFloat)] = []
        let topMargin = 13
        let bottomMargin = rows - 44
        for row in topMargin..<(rows - bottomMargin) {
            let isOdd = row % 2 == 1
            let colCount = isOdd ? cols - 1 : cols
            let xOffset: CGFloat = isOdd ? 0 : -tileW / 2
            for col in 1..<(colCount - 1) {
                if gardenLayoutMap[row][col].canSpawnAnimal {
                    let x = xOffset + CGFloat(col) * tileW + tileW / 2
                    let y = offsetY + CGFloat(row) * rowStep + tileH / 2
                    positions.append((x, y))
                }
            }
        }
        return positions
    }

    /// 植物配置（画面内に確実に見えるタイルのみ）
    private var plantGrid: [Int: String] {
        var grassTiles: [(col: Int, row: Int)] = []
        // 上の茂み+遷移(row 0-12)と下の遷移+茂み(row 44-55)を除外
        // 左右端(col 0, 最終col)も除外 → 見切れ用の茂み列
        let topMargin = 13
        let bottomMargin = rows - 44
        for row in topMargin..<(rows - bottomMargin) {
            let isOdd = row % 2 == 1
            let colCount = isOdd ? cols - 1 : cols
            for col in 1..<(colCount - 1) where gardenLayoutMap[row][col].canPlacePlant {
                if gardenDecorationMap[row][col] == .none {
                    grassTiles.append((col, row))
                }
            }
        }
        var rng = SeededRandomNumberGenerator(seed: 42)
        grassTiles.shuffle(using: &rng)

        var dict: [Int: String] = [:]
        let count = min(plantCount, grassTiles.count)
        for i in 0..<count {
            let key = grassTiles[i].row * cols + grassTiles[i].col
            dict[key] = flowerDecoAssets[i % flowerDecoAssets.count]
        }
        return dict
    }

    // MARK: - タイル画像ビュー
    @ViewBuilder
    private func tileImage(name: String, size: CGFloat) -> some View {
        if UIImage(named: name) != nil {
            Image(name)
                .resizable()
                .interpolation(.none)
                .frame(width: size, height: size)
        } else {
            Color.green.opacity(0.3)
                .frame(width: size, height: size)
        }
    }

    // MARK: - デコレーション画像ビュー
    @ViewBuilder
    private func decoImage(name: String, tileSize: CGFloat) -> some View {
        if UIImage(named: name) != nil {
            Image(name)
                .resizable()
                .interpolation(.none)
                .frame(width: tileSize * 0.7, height: tileSize * 0.7)
        } else {
            EmptyView()
        }
    }
}

// MARK: - 家具スロット定義
struct FurnitureSlotData: Identifiable {
    let id: String
    let name: String
    let emoji: String
}

let allFurnitureSlots: [FurnitureSlotData] = [
    FurnitureSlotData(id: "bench",     name: "ベンチ",   emoji: "🪑"),
    FurnitureSlotData(id: "fountain",  name: "噴水",    emoji: "⛲"),
    FurnitureSlotData(id: "lantern",   name: "灯籠",    emoji: "🏮"),
    FurnitureSlotData(id: "statue",    name: "石像",    emoji: "🗿"),
    FurnitureSlotData(id: "table",     name: "テーブル", emoji: "🪵"),
    FurnitureSlotData(id: "birdhouse", name: "巣箱",    emoji: "🏠"),
]

// MARK: - シード付き乱数生成器
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) { state = seed }

    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}
