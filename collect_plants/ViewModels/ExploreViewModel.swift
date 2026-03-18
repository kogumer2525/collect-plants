import SwiftUI
import CoreLocation

@Observable
class ExploreViewModel {
    var capturedImage: UIImage?
    var candidates: [PlantCandidate] = []
    var selectedCandidate: PlantCandidate?
    var currentLocation: CLLocation?
    var isIdentifying = false
    var showResult = false
    var errorMessage: String?
    var isSaving = false

    let cameraService = CameraService()
    private let plantNetService = PlantNetService.shared
    private let locationService = LocationService.shared
    private let coreDataService = CoreDataService.shared

    func captureAndIdentify() async {
        do {
            let image = try await cameraService.capturePhoto()
            capturedImage = image
            isIdentifying = true
            errorMessage = nil

            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                errorMessage = "画像の変換に失敗しました"
                isIdentifying = false
                return
            }

            async let identifyTask = plantNetService.identify(imageData: imageData)
            async let locationTask = locationService.getCurrentLocation()

            let (results, location) = try await (identifyTask, locationTask)

            candidates = results
            currentLocation = location
            selectedCandidate = results.first
            showResult = true
            isIdentifying = false
        } catch {
            errorMessage = error.localizedDescription
            isIdentifying = false
        }
    }

    func selectCandidate(_ candidate: PlantCandidate) {
        selectedCandidate = candidate
    }

    func registerPlant() async {
        guard let candidate = selectedCandidate,
              let location = currentLocation,
              let image = capturedImage,
              let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        isSaving = true

        do {
            async let locationNameTask = locationService.reverseGeocode(location: location)
            async let wikiInfoTask = WikipediaService.shared.fetchPlantInfo(scientificName: candidate.scientificName)
            
            let locationName = try await locationNameTask
            var wikiInfo = try await wikiInfoTask

            // Wikipedia APIで「日本語名不明」となった場合、Mistralにフォールバック
            if wikiInfo.japaneseName == "日本語名不明" {
                print("[ExploreVM] Wikipedia で日本語名不明 → Mistral にフォールバック")
                do {
                    let mistralInfo = try await MistralService.shared.fetchPlantInfo(scientificName: candidate.scientificName)
                    print("[ExploreVM] Mistral 成功: \(mistralInfo.japaneseName)")
                    wikiInfo = WikipediaPlantInfo(
                        japaneseName: mistralInfo.japaneseName,
                        description: mistralInfo.description,
                        source: "mistral"
                    )
                } catch {
                    // Mistralも失敗した場合は、Wikipediaの結果（「日本語名不明」）をそのまま使用
                    print("[ExploreVM] Mistral フォールバック失敗: \(error.localizedDescription)")
                }
            } else {
                print("[ExploreVM] Wikipedia 成功: \(wikiInfo.japaneseName)")
            }

            _ = coreDataService.savePlantRecord(
                plantName: candidate.plantName,
                scientificName: candidate.scientificName,
                imageData: imageData,
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                locationName: locationName,
                confidence: candidate.score,
                japaneseName: wikiInfo.japaneseName,
                description: wikiInfo.description,
                source: wikiInfo.source
            )

            resetState()
        } catch {
            errorMessage = error.localizedDescription
        }

        isSaving = false
    }

    func resetState() {
        capturedImage = nil
        candidates = []
        selectedCandidate = nil
        currentLocation = nil
        showResult = false
        errorMessage = nil
    }
}
