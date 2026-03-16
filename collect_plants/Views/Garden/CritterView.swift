import SwiftUI

// MARK: - スプライトストリップアニメーション
/// 横一列に並んだスプライトストリップ画像を1フレームずつ切り出して表示する
struct SpriteStripView: View {
    let assetName: String
    let frameCount: Int
    let frameHeight: CGFloat
    let currentFrame: Int
    let displaySize: CGFloat

    var body: some View {
        if UIImage(named: assetName) != nil {
            let stripWidth = displaySize * CGFloat(frameCount)

            Image(assetName)
                .resizable()
                .interpolation(.none)
                .frame(width: stripWidth, height: displaySize)
                .offset(x: -CGFloat(currentFrame) * displaySize + stripWidth / 2 - displaySize / 2)
                .frame(width: displaySize, height: displaySize)
                .clipped()
        }
    }
}

// MARK: - 動物1体の表示・アニメーション・移動を管理
struct CritterView: View {
    let critter: GardenCritter
    let dirtTilePositions: [(x: CGFloat, y: CGFloat)]
    let tileSize: CGFloat

    @State private var currentFrame: Int = 0
    @State private var animation: CritterAnimation = .idle
    @State private var direction: CritterDirection = .SE
    @State private var position: CGPoint = .zero
    @State private var targetPosition: CGPoint = .zero
    @State private var isInitialized = false

    private let animationInterval: TimeInterval = 0.15
    private let moveInterval: TimeInterval = 3.0

    var body: some View {
        let assetName = critter.type.assetName(direction: direction, animation: animation)
        let frameCount = critter.type.frameCount(for: animation)
        let displaySize = tileSize * 0.7

        let flipX = (direction == .NE || direction == .SE)

        SpriteStripView(
            assetName: assetName,
            frameCount: frameCount,
            frameHeight: critter.type.frameHeight,
            currentFrame: currentFrame,
            displaySize: displaySize
        )
        .scaleEffect(x: flipX ? -1 : 1, y: 1)
        .position(position)
        .onAppear {
            guard !isInitialized else { return }
            isInitialized = true
            // 初期位置をランダムなdirtタイルに設定
            var rng = SeededRandomNumberGenerator(seed: UInt64(critter.id * 77 + 13))
            if let startTile = dirtTilePositions.randomElement(using: &rng) {
                position = CGPoint(x: startTile.x, y: startTile.y)
                targetPosition = position
            }
            startAnimationTimer()
            startMovementTimer()
        }
    }

    private func startAnimationTimer() {
        Timer.scheduledTimer(withTimeInterval: animationInterval, repeats: true) { _ in
            let frameCount = critter.type.frameCount(for: animation)
            currentFrame = (currentFrame + 1) % frameCount
        }
    }

    private func startMovementTimer() {
        // 初回はランダムな遅延で開始（一斉に動かない）
        let initialDelay = Double(critter.id) * 0.8 + 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + initialDelay) {
            moveToNextTile()
            Timer.scheduledTimer(withTimeInterval: moveInterval, repeats: true) { _ in
                moveToNextTile()
            }
        }
    }

    private func moveToNextTile() {
        guard !dirtTilePositions.isEmpty else { return }

        // 近くのdirtタイルからランダムに次の目的地を選ぶ
        let nearbyTiles = dirtTilePositions.filter { tile in
            let dx = tile.x - position.x
            let dy = tile.y - position.y
            let dist = sqrt(dx * dx + dy * dy)
            return dist > 5 && dist < tileSize * 3
        }

        let target: (x: CGFloat, y: CGFloat)
        if let nearby = nearbyTiles.randomElement() {
            target = nearby
        } else if let any = dirtTilePositions.randomElement() {
            target = any
        } else {
            return
        }

        targetPosition = CGPoint(x: target.x, y: target.y)

        // 方向を決定
        let dx = targetPosition.x - position.x
        let dy = targetPosition.y - position.y
        if dx > 0 && dy > 0 {
            direction = .SE
        } else if dx > 0 && dy <= 0 {
            direction = .NE
        } else if dx <= 0 && dy > 0 {
            direction = .SW
        } else {
            direction = .NW
        }

        // walk アニメーションに切り替え
        animation = .walk
        currentFrame = 0

        // アニメーション付き移動
        withAnimation(.easeInOut(duration: moveInterval * 0.8)) {
            position = targetPosition
        }

        // 到着後にidleに戻す
        DispatchQueue.main.asyncAfter(deadline: .now() + moveInterval * 0.8) {
            animation = .idle
            currentFrame = 0
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
