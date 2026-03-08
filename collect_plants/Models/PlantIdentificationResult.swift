import Foundation

struct PlantIdentificationResponse: Codable {
    let results: [PlantCandidate]
}

struct PlantCandidate: Codable, Identifiable {
    let id = UUID()
    let score: Double
    let species: Species

    var plantName: String {
        species.commonNames.first ?? species.scientificNameWithoutAuthor
    }

    var scientificName: String {
        species.scientificNameWithoutAuthor
    }

    enum CodingKeys: String, CodingKey {
        case score, species
    }

    struct Species: Codable {
        let scientificNameWithoutAuthor: String
        let commonNames: [String]
    }
}
