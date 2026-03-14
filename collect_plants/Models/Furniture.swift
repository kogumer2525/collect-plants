import Foundation

struct Furniture: Identifiable, Codable {
    let id: String
    let name: String
    let imageName: String
    let cost: Int
    let description: String

    static let allItems: [Furniture] = [
        Furniture(id: "ball", name: "ボール", imageName: "furniture_ball", cost: 15, description: "カラフルなボール"),
        Furniture(id: "nest", name: "鳥の巣箱", imageName: "furniture_nest", cost: 20, description: "野鳥が来るかも"),
        Furniture(id: "chair", name: "椅子", imageName: "furniture_chair", cost: 30, description: "休憩に"),
        Furniture(id: "bench", name: "ベンチ", imageName: "furniture_bench", cost: 40, description: "みんなで座れる"),
        Furniture(id: "cat_tower", name: "キャットタワー", imageName: "furniture_cat_tower", cost: 100, description: "猫用？")
    ]

    static func byId(_ id: String) -> Furniture? {
        allItems.first { $0.id == id }
    }
}
