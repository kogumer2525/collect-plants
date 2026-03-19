import SwiftUI

// MARK: - スプライトストリップアニメーション（boar, stag 用）
/// 横一列に並んだスプライトストリップ画像を1フレームずつ切り出して表示する
/// 画像の実際のピクセル寸法からフレーム幅を算出する
struct SpriteStripView: View {
    let assetName: String
    let frameCount: Int
    let currentFrame: Int
    let displayHeight: CGFloat

    var body: some View {
        if let uiImage = UIImage(named: assetName) {
            // 実際の画像サイズからフレーム1枚の幅を算出
            let imgW = uiImage.size.width
            let imgH = uiImage.size.height
            let frameW = imgW / CGFloat(frameCount)
            let aspect = frameW / imgH  // フレームのアスペクト比（幅/高さ）
            let displayW = displayHeight * aspect

            let stripWidth = displayW * CGFloat(frameCount)

            Image(assetName)
                .resizable()
                .interpolation(.none)
                .frame(width: stripWidth, height: displayHeight)
                .offset(x: -CGFloat(currentFrame) * displayW + stripWidth / 2 - displayW / 2)
                .frame(width: displayW, height: displayHeight)
                .clipped()
        }
    }
}

// MARK: - スプライトシートアニメーション（wolf 用）
/// グリッド状に並んだスプライトシートから特定の行・列のフレームを表示する
/// 画像の実際のピクセル寸法からフレームサイズを算出する
struct SpriteSheetView: View {
    let assetName: String
    let columns: Int
    let rows: Int
    let currentFrame: Int
    let row: Int
    let displayHeight: CGFloat

    var body: some View {
        if let uiImage = UIImage(named: assetName) {
            let imgW = uiImage.size.width
            let imgH = uiImage.size.height
            let frameW = imgW / CGFloat(columns)
            let frameH = imgH / CGFloat(rows)
            let aspect = frameW / frameH
            let displayW = displayHeight * aspect

            let sheetWidth = displayW * CGFloat(columns)
            let sheetHeight = displayHeight * CGFloat(rows)

            Image(assetName)
                .resizable()
                .interpolation(.none)
                .frame(width: sheetWidth, height: sheetHeight)
                .offset(
                    x: -CGFloat(currentFrame) * displayW + sheetWidth / 2 - displayW / 2,
                    y: -CGFloat(row) * displayHeight + sheetHeight / 2 - displayHeight / 2
                )
                .frame(width: displayW, height: displayHeight)
                .clipped()
        }
    }
}

// MARK: - 動物1体の表示・アニメーション・移動を管理
struct CritterView: View {
    let critter: GardenCritter
    let walkableTilePositions: [(x: CGFloat, y: CGFloat)]
    let tileSize: CGFloat

    @State private var currentFrame: Int = 0
    @State private var animation: CritterAnimation = .idle
    @State private var direction: CritterDirection = .SE
    @State private var position: CGPoint = .zero
    @State private var isInitialized = false

    private let animationInterval: TimeInterval = 0.15
    /// 隣接タイル1つへの移動時間（ゆっくり）
    private let stepDuration: TimeInterval = 3.0

    var body: some View {
        let displayH = tileSize * 0.7 * critter.type.displayScale

        Group {
            switch critter.type.spriteFormat {
            case .strip:
                SpriteStripView(
                    assetName: critter.type.stripAssetName(direction: direction, animation: animation),
                    frameCount: critter.type.frameCount(for: animation),
                    currentFrame: currentFrame,
                    displayHeight: displayH
                )

            case .sheet:
                SpriteSheetView(
                    assetName: critter.type.sheetAssetName(animation: animation),
                    columns: critter.type.sheetColumns(for: animation),
                    rows: 4,
                    currentFrame: currentFrame,
                    row: direction.wolfRow,
                    displayHeight: displayH
                )
            }
        }
        .position(position)
        .onAppear {
            guard !isInitialized else { return }
            isInitialized = true
            if !walkableTilePositions.isEmpty {
                let index = Int.random(in: 0..<walkableTilePositions.count)
                let tile = walkableTilePositions[index]
                position = CGPoint(x: tile.x, y: tile.y)
            }
            startAnimationTimer()
            let initialDelay = Double(critter.id) * 0.8 + 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + initialDelay) {
                stepToNeighbor()
            }
        }
    }

    private func startAnimationTimer() {
        Timer.scheduledTimer(withTimeInterval: animationInterval, repeats: true) { _ in
            let frameCount = critter.type.frameCount(for: animation)
            currentFrame = (currentFrame + 1) % frameCount
        }
    }

    /// 隣接する歩行可能タイルに1歩だけ移動する
    /// タイル間を直線で結ぶので、隣接タイルなら経路上に非歩行タイルを通らない
    private func stepToNeighbor() {
        guard !walkableTilePositions.isEmpty else { return }

        // 隣接タイル = 距離が tileSize * 1.2 以内（斜め隣接含む）
        let maxNeighborDist = tileSize * 1.2
        let neighbors = walkableTilePositions.filter { tile in
            let dx = tile.x - position.x
            let dy = tile.y - position.y
            let dist = sqrt(dx * dx + dy * dy)
            return dist > 1 && dist <= maxNeighborDist
        }

        guard let target = neighbors.randomElement() else {
            // 隣接がない場合（孤立タイル）→ 最も近いタイルにジャンプ
            if let closest = walkableTilePositions
                .filter({ sqrt(pow($0.x - position.x, 2) + pow($0.y - position.y, 2)) > 1 })
                .min(by: { sqrt(pow($0.x - position.x, 2) + pow($0.y - position.y, 2)) < sqrt(pow($1.x - position.x, 2) + pow($1.y - position.y, 2)) }) {
                position = CGPoint(x: closest.x, y: closest.y)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration) {
                stepToNeighbor()
            }
            return
        }

        let nextPos = CGPoint(x: target.x, y: target.y)

        // 移動方向から向きを決定
        let dx = nextPos.x - position.x
        let dy = nextPos.y - position.y
        if dx > 0 && dy > 0 {
            direction = .SE
        } else if dx > 0 && dy <= 0 {
            direction = .NE
        } else if dx <= 0 && dy > 0 {
            direction = .SW
        } else {
            direction = .NW
        }

        animation = .walk
        currentFrame = 0

        withAnimation(.linear(duration: stepDuration)) {
            position = nextPos
        }

        // 1歩完了後、すぐ次の1歩へ（停止なし）
        DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration) {
            stepToNeighbor()
        }
    }
}

// MARK: - RandomElement with custom RNG
private extension Array {
    func randomElement(using rng: inout SeededRandomNumberGenerator) -> Element? {
        guard !isEmpty else { return nil }
        let index = Int(rng.next() % UInt64(count))
        return self[index]
    }
}
