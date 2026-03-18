import Foundation

struct Furniture: Identifiable, Codable {
    let id: String
    let name: String
    let imageName: String
    let cost: Int
    let description: String
    let gardenRow: Int        // 庭の固定row
    let gardenCol: Int        // 庭の固定col
    let widthInTiles: CGFloat // 表示サイズ（タイル幅の倍率）

    static let allItems: [Furniture] = [
        Furniture(id: "ball",    name: "サッカーボール", imageName: "furniture_soccer_ball", cost: 10, description: "カラフルなボール",     gardenRow: 33, gardenCol: 4, widthInTiles: 1.0),
        Furniture(id: "bench",   name: "ベンチ",        imageName: "furniture_chair",       cost: 20, description: "みんなで座れる",       gardenRow: 42, gardenCol: 6, widthInTiles: 2.0),
        Furniture(id: "bird",    name: "鳥籠",         imageName: "furniture_bird",        cost: 30, description: "野鳥が来るかも",       gardenRow: 37, gardenCol: 7, widthInTiles: 1.5),
        Furniture(id: "bicycle", name: "自転車",        imageName: "furniture_bicycle",     cost: 40, description: "散歩のお供に",         gardenRow: 47, gardenCol: 4, widthInTiles: 2.5),
        Furniture(id: "swing",   name: "ブランコ",      imageName: "furniture_swing",       cost: 50, description: "ゆらゆら揺れる",       gardenRow: 28, gardenCol: 1, widthInTiles: 2.5),
        Furniture(id: "slide",   name: "滑り台",        imageName: "furniture_slide",       cost: 60, description: "楽しいすべり台",       gardenRow: 34, gardenCol: 2, widthInTiles: 2.5),
    ]

    static func byId(_ id: String) -> Furniture? {
        allItems.first { $0.id == id }
    }
}
