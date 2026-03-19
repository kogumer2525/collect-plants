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
    case lake           // 湖（tile_104）
    case lakeDeep       // 湖（tile_106）
    case lakeSide       // 湖に一番近い草（tile_040）
    case lakeEdge       // 湖の周り（tile_003）
    case lakeEdgeOuter  // さらに外側（tile_009）
    case dirtFlat       // 平らな土（tile_018）

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
        case .path:         return "tile_063"
        case .pathEdge:     return "tile_016"
        case .stonePath:    return "tile_061"
        case .water:        return "tile_095"
        case .waterEdge:    return "tile_069"
        case .lake:         return "tile_104"
        case .lakeDeep:     return "tile_106"
        case .lakeSide:     return "tile_040"
        case .lakeEdge:     return "tile_003"
        case .lakeEdgeOuter: return "tile_009"
        case .dirtFlat:      return "tile_018"
        }
    }

    /// 花が生えるタイル（草系 + lakeSide）
    var canPlacePlant: Bool {
        switch self {
        case .grassLight, .grassMedium, .grassDense, .grassLush, .lakeSide:
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

    /// 凹み量（y座標を下にずらす倍率、tileH基準）
    var depthOffset: CGFloat {
        switch self {
        case .lake, .lakeDeep, .lakeSide, .lakeEdge: return 0.5
        case .lakeEdgeOuter:                          return 0.1
        case .dirtFlat:                               return 0.5
        case .path:                                   return -0.4
        default:                                      return 0.0
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

    /// 動物が歩けるタイル（GL と P のみ）
    var canWalk: Bool {
        switch self {
        case .grassLight, .path: return true
        default: return false
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
    case logCross   // 丸太十字 (tile_049)
    case logSide    // 丸太横   (tile_051)
    case logBack    // 丸太後ろ (tile_052)
    case stump
    case rockSmall
    case rockLarge
    case dirt1      // tile_053
    case dirt2      // tile_054
    case dirt3      // tile_055
    case dirt4      // tile_056
    case dirt5      // tile_057
    case dirt6      // tile_058
    case dirt7      // tile_059
    case dirt8      // tile_060

    /// 凹み量（y座標を下にずらす倍率、tileH基準）
    var depthOffset: CGFloat {
        switch self {
        case .log, .logCross, .logSide, .logBack: return 0.5
        case .dirt1, .dirt2, .dirt3, .dirt4,
             .dirt5, .dirt6, .dirt7, .dirt8:      return 0.5
        default:                                   return 0.0
        }
    }

    var assetName: String? {
        switch self {
        case .none:         return nil
        case .flowerRed:    return "tile_041"
        case .flowerPurple: return "tile_044"
        case .bush:         return "tile_045"
        case .tallGrass:    return "tile_043"
        case .log:          return "tile_048"
        case .logCross:     return "tile_049"
        case .logSide:      return "tile_051"
        case .logBack:      return "tile_052"
        case .stump:        return "tile_051"
        case .rockSmall:    return "tile_062"
        case .rockLarge:    return "tile_053"
        case .dirt1:        return "tile_053"
        case .dirt2:        return "tile_054"
        case .dirt3:        return "tile_055"
        case .dirt4:        return "tile_056"
        case .dirt5:        return "tile_057"
        case .dirt6:        return "tile_058"
        case .dirt7:        return "tile_059"
        case .dirt8:        return "tile_060"
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
private let LK = TileType.lake
private let LD = TileType.lakeDeep
private let LS = TileType.lakeSide
private let LE = TileType.lakeEdge
private let LO = TileType.lakeEdgeOuter
private let DF = TileType.dirtFlat

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
    [GB, GB, GB, GB, GB, GB, GB, GL, GL, GB],  // row 2
     [GB, GB, GB, GB, GB, GB, GL, GL, GL],     // row 3
    [GB, GB, GB, GB, GB, GB, GL, GL, GL, GB],  // row 4
     [GB, GB, GB, GB, GB, GL, GL, GL, GL],     // row 5
    [GB, GB, GB, GB, GB, GL, GL, GL, GL, GB],  // row 6
     [GB, GB, GB, GB, GL, GL, GL, GL, GL],     // row 7
    [GB, GB, GB, GB, GL, GL, GL, GL, GL, GB],  // row 8
    // ===== 茂み→草遷移 =====
     [GB, GB, GB, GD, GD, GD, GD, GD, GL],     // row 9
    [GB, GB, GB, GL, GL, GL, LO, GL, GD, GB],  // row 10
     [GB, GB, GL, GL, GL, LO, LO, GL, GL],     // row 11
    [GB, GB, GL, GL, LO, LO, LE, DF, GL, GB],  // row 12
     [GB, GL, GL, LO, LO, LE, LS, DF, LO],     // row 13
    [GB, GL, GL, GL, LO, LE, LS, LS, DF, LO],  // row 14
     [GL, GL, GL, LO, LS, LS, LS, LS, DF],     // row 15
    [GB, GL, GL, LO, LE, LS, LK, LS, DF, LO],  // row 16
     [GL, GL, LO, LE, LS, LK, LS, LS, DF],     // row 17
    [GB, GL, LO, LE, LS, LK, LK, LS, LS, LE],  // row 18 
     [GL, GL, LO, LE, LS, LK, LK, LS, LE],     // row 19  
    [GB, GL, GL, LO, LS, LK, LK, LS, LS, LE],  // row 20
     [GL, GL, LO, LE, LK, LK, LK, LS, LE],     // row 21
    [GB, GL, GL, LO, LS, LK, LK, LS, LE, LO],  // row 22
     [GL, GL, LO, LE, LS, LK, LK, LS, LO],     // row 23
    [GB, GL, GL, LO, LE, LK, LK, LS, LE, LO],  // row 24
     [GL, GL, GL, LO, LS, LK, LS, LE, LO],     // row 25
    [GB, GL, GL, LO, LE, LS, LS, LE, LO, GB],  // row 26
     [GL, GL, GL, LO, LE, LS, LE, LO, P],     // row 27
    [GB, GL, GL, GL, LO, LE, LE, LO, P, P],  // row 28
     [GL, GL, GL, GL, LO, LE, LO, P, P],     // row 29
    [GB, GL, GL, GL, GL, LO, LO, P, P, P],  // row 30
     [GL, GL, GL, GL, GL, LO, P, P, P],     // row 31
    [GB, GL, GL, GL, GL, GL, P, P, P, GB],  // row 32
     [GL, GL, GL, GL, GL, P, P, P, GL],     // row 33
    [GB, GL, GL, GL, GL, P, P, P, GL, GB],  // row 34
     [GL, GL, GL, GL, P, P, P, GL, GL],     // row 35
    // ===== 草原 + 水辺（塊で配置）=====
    [GB, GL, GL, GL, P, P, P, GL, GL, GB],  // row 36  水辺（右寄り）
     [GL, GL, GL, P, P, P, GL, GL, GL],     // row 37
    [GB, GL, GL, P, P, P, GL, GL, GL, GB],  // row 38
     [GL, GL, P, P, P, GL, GL, GL, GL],     // row 39
    [GB, GL, P, P, P, GL, GL, GL, GL, GB],  // row 40  水辺（左寄り）
     [GL, P, P, P, GL, GL, GL, GL, GL],     // row 41
    [GB, P, P, P, GL, GL, GL, GL, GL, GB],  // row 42
     [P, P, P, GL, GL, GL, GL, GL, GB],     // row 43
    // ===== 草→茂み遷移 =====
    [P, P, P, GL, GL, GL, GL, GL, GB, GB],  // row 44
     [P, P, GM, GL, GL, GL, GL, GB, GB],     // row 45
    [P, P, GL, GL, GL, GL, GL, GB, GB, GB],  // row 46
     [P, GL, GL, GL, GL, GL, GB, GB, GB],     // row 47
    [P, GL, GL, GL, GL, GL, GB, GB, GB, GB],  // row 48
    // ===== 下端: 茂み多め（見切れ前提） =====
     [GL, GL, GL, GL, GL, GB, GB, GB, GB],     // row 49
    [GB, GL, GL, GL, GL, GB, GB, GB, GB, GB],  // row 50
     [GL, GL, GL, GL, GB, GB, GB, GB, GB],     // row 51
    [GB, GL, GL, GL, GB, GB, GB, GB, GB, GB],  // row 52
     [GL, GL, GL, GB, GB, GB, GB, GB, GB],     // row 53
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
        [__, __, __, __, __, __, __, __, __, __],  // row 0
         [__, __, __, __, __, __, __, __, __],     // row 1
        [__, __, __, __, __, __, __, __, __, __],  // row 2
         [__, __, __, __, __, __, __, __, __],     // row 3
        [__, __, __, __, __, __, __, __, __, __],  // row 4
         [__, __, __, __, __, __, __, __, __],     // row 5
        [__, __, __, __, __, __, __, __, __, __],  // row 6
         [__, __, __, __, __, __, __, __, __],     // row 7
        [__, __, __, __, __, __, __, __, __, __],  // row 8
        // row 9-12: 遷移
         [__, TG, TG, __, __, __, __, TG, __],
        [__, TG, __, __, __, __, __, __, TG, __],
         [__, __, __, __, __, __, __, __, __],
        [__, __, __, __, __, __, __, .dirt7, __, __],
        // row 13-23: 草原+道
         [__, __, __, __, __, __, __, .dirt8, __],
        [__, __, __, __, __, __, .logBack, __, .dirt5, __],
         [__, __, __, __, __, .logSide, .logCross, __, .dirt4],
        [__, __, __, __, __, __, __, __, .dirt7, __],
         [__, __, __, __, __, __, __, __, .dirt8],
        [__, __, __, __, __, __, __, __, __, .dirt1],
         [__, __, __, __, __, __, __, __, __],
        [__, __, __, __, __, __, __, __, __, __],
         [__, __, __, __, __, __, __, __, __],
        [__, __, __, __, __, __, __, __, __, __],
         [__, __, __, __, __, __, __, __, __],
        // row 24-27: 中心広場
        [__, __, __, __, __, __, __, __, __, __],
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
        [__, __, __, __, __, __, __, __, __, __],  // row 44
         [__, TG, __, __, __, __, __, TG, __],     // row 45
        [__, __, __, __, __, __, __, __, __, __],  // row 46
         [__, __, TG, __, __, __, TG, __, __],     // row 47
        [__, __, __, __, __, __, __, __, __, __],  // row 48
        // row 49-55: 茂み
         [__, __, __, __, __, __, __, __, __],     // row 49
        [__, __, __, __, __, __, __, __, __, __],  // row 50
         [__, __, __, __, __, __, __, __, __],     // row 51
        [__, __, __, __, __, __, __, __, __, __],  // row 52
         [__, __, __, __, __, __, __, __, __],     // row 53
        [__, __, __, __, __, __, __, __, __, __],  // row 54
         [__, __, __, __, __, __, __, __, __],     // row 55  全GB
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
            let walkPositions = walkableTilePositions(tileW: tileW, tileH: tileH, rowStep: rowStep, offsetY: offsetY)

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
                        let tileY = y + tileH * tileType.depthOffset
                        tileImage(name: tileType.assetName, size: tileImgSize)
                            .position(x: x, y: tileY)

                        // 固定デコレーション
                        if let decoAsset = deco.assetName {
                            decoImage(name: decoAsset, tileSize: tileImgSize)
                                .position(x: x, y: y - tileH * 0.25 + tileH * deco.depthOffset)
                        }

                        // 植物（図鑑登録で増える花）
                        if let flowerAsset = plants[key] {
                            decoImage(name: flowerAsset, tileSize: tileImgSize)
                                .position(x: x, y: y - tileH * 0.25)
                        }

                        // 家具（購入済みのものを固定座標に表示、GLタイルのみ）
                        if tileType == .grassLight,
                           let furniture = Furniture.allItems.first(where: {
                            ownedFurnitureIDs.contains($0.id) && $0.gardenRow == row && $0.gardenCol == col
                        }) {
                            let fw = tileW * furniture.widthInTiles
                            Image(furniture.imageName)
                                .renderingMode(.original)
                                .resizable()
                                .interpolation(.none)
                                .scaledToFit()
                                .frame(width: fw)
                                .position(x: x, y: y - fw / 2)
                        }
                    }
                }

                // 動物レイヤー（タイルの上に描画）
                ForEach(critters) { critter in
                    CritterView(
                        critter: critter,
                        walkableTilePositions: walkPositions,
                        tileSize: tileImgSize
                    )
                }
            }
            .frame(width: screenW, height: screenH)
            .clipped()
        }
    }

    /// 歩行可能タイルの画面座標一覧（動物の移動先候補）
    /// - GL・Pタイルのうち、画面に見える範囲のみ（見切れ端を除外）
    /// - 家具の表示領域と重なるタイルを除外（画面座標ベースで判定）
    private func walkableTilePositions(tileW: CGFloat, tileH: CGFloat, rowStep: CGFloat, offsetY: CGFloat) -> [(x: CGFloat, y: CGFloat)] {
        // 家具の表示矩形を画面座標で計算（動物がこの範囲に入らないようにする）
        struct FurnitureRect {
            let minX: CGFloat, maxX: CGFloat, minY: CGFloat, maxY: CGFloat
        }
        let furnitureRects: [FurnitureRect] = Furniture.allItems
            .filter { ownedFurnitureIDs.contains($0.id) }
            .map { f in
                let isOdd = f.gardenRow % 2 == 1
                let xOff: CGFloat = isOdd ? 0 : -tileW / 2
                let fx = xOff + CGFloat(f.gardenCol) * tileW + tileW / 2
                let fy = offsetY + CGFloat(f.gardenRow) * rowStep + tileH / 2
                let fw = tileW * f.widthInTiles
                let fh = fw * 1.5  // 画像アスペクト比
                // 家具の中心は (fx, fy - fw/2)、サイズは fw x fh
                let centerY = fy - fw / 2
                return FurnitureRect(
                    minX: fx - fw / 2, maxX: fx + fw / 2,
                    minY: centerY - fh / 2, maxY: centerY + fh / 2
                )
            }

        // GBに隣接するタイルを除外するためのヘルパー
        func isNotBush(row r: Int, col c: Int) -> Bool {
            guard r >= 0 && r < rows else { return false }
            let isOdd = r % 2 == 1
            let cc = isOdd ? cols - 1 : cols
            guard c >= 0 && c < cc else { return false }
            return gardenLayoutMap[r][c] != .grassBush
        }

        var positions: [(x: CGFloat, y: CGFloat)] = []
        let topMargin = 13
        let bottomMargin = rows - 44
        for row in topMargin..<(rows - bottomMargin) {
            let isOdd = row % 2 == 1
            let colCount = isOdd ? cols - 1 : cols
            let xOffset: CGFloat = isOdd ? 0 : -tileW / 2

            // 端の見切れ列を除外
            let colStart = isOdd ? 1 : 2
            let colEnd = isOdd ? colCount - 1 : colCount - 2

            for col in colStart..<colEnd {
                guard gardenLayoutMap[row][col].canWalk else { continue }

                // 下側にGBがあるタイルを除外（茂みに突っ込んで見えるのを防ぐ）
                if !isNotBush(row: row + 1, col: col) { continue }

                let x = xOffset + CGFloat(col) * tileW + tileW / 2
                let y = offsetY + CGFloat(row) * rowStep + tileH / 2

                // 家具の表示領域と重なるか判定（タイトめに判定）
                let margin = tileW * 0.1
                let overlaps = furnitureRects.contains { rect in
                    x > rect.minX - margin && x < rect.maxX + margin &&
                    y > rect.minY - margin && y < rect.maxY + margin
                }
                if overlaps { continue }

                positions.append((x, y))
            }
        }
        return positions
    }

    /// 植物配置（画面内に確実に見えるタイルのみ、家具タイルを除外）
    private var plantGrid: [Int: String] {
        // 家具が置かれている座標を集める
        let furnitureTiles: Set<Int> = Set(
            Furniture.allItems
                .filter { ownedFurnitureIDs.contains($0.id) }
                .map { $0.gardenRow * cols + $0.gardenCol }
        )

        var grassTiles: [(col: Int, row: Int)] = []
        // 上の茂み+遷移(row 0-12)と下の遷移+茂み(row 44-55)を除外
        // 左右端(col 0, 最終col)も除外 → 見切れ用の茂み列
        let topMargin = 13
        let bottomMargin = rows - 44
        for row in topMargin..<(rows - bottomMargin) {
            let isOdd = row % 2 == 1
            let colCount = isOdd ? cols - 1 : cols
            for col in 1..<(colCount - 1) where gardenLayoutMap[row][col].canPlacePlant {
                let key = row * cols + col
                if gardenDecorationMap[row][col] == .none && !furnitureTiles.contains(key) {
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
