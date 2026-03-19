import SwiftUI
import CoreLocation
import PhotosUI
import ImageIO

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
    var showImagePicker = false
    var discoveryDate: Date? // メタデータから取得した撮影日時

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
              let image = capturedImage,
              let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        isSaving = true

        do {
            // 位置情報がある場合は逆ジオコーディング実行
            let locationName: String
            let latitude: Double
            let longitude: Double
            
            if let location = currentLocation {
                locationName = try await locationService.reverseGeocode(location: location)
                latitude = location.coordinate.latitude
                longitude = location.coordinate.longitude
            } else {
                // 位置情報がない場合
                locationName = "不明"
                latitude = 0.0
                longitude = 0.0
            }
            
            // 発見日を決定（メタデータから抽出した日時を使用、ない場合は今日）
            let recordDate = discoveryDate ?? Date()
            print("[ExploreVM] discoveryDate: \(discoveryDate?.description ?? "nil"), recordDate: \(recordDate)")
            
            // デバッグ：位置情報の確認
            print("[ExploreVM] Location - latitude: \(latitude), longitude: \(longitude), locationName: \(locationName)")
            
            var wikiInfo = try await WikipediaService.shared.fetchPlantInfo(scientificName: candidate.scientificName)

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
                    print("[ExploreVM] Mistral フォールバック失敗: \(error.localizedDescription)")
                }
            } else {
                print("[ExploreVM] Wikipedia 成功: \(wikiInfo.japaneseName)")
            }

            _ = coreDataService.savePlantRecord(
                plantName: candidate.plantName,
                scientificName: candidate.scientificName,
                imageData: imageData,
                latitude: latitude,
                longitude: longitude,
                locationName: locationName,
                confidence: candidate.score,
                japaneseName: wikiInfo.japaneseName,
                description: wikiInfo.description,
                source: wikiInfo.source,
                date: recordDate
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
        discoveryDate = nil
    }

    /// ギャラリーから選択した UIImage とメタデータを使用して識別
    /// ギャラリーから選択した UIImage を識別
    /// 発見日時は現在時刻、発見場所は不明にセット（後で詳細画面で手入力修正可能）
    func identifyFromGalleryImage(_ image: UIImage) async {
        print("[ExploreVM] identifyFromGalleryImage called")
        capturedImage = image
        isIdentifying = true
        errorMessage = nil
        currentLocation = nil
        discoveryDate = Date()

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            errorMessage = "画像の変換に失敗しました"
            isIdentifying = false
            return
        }

        do {
            let results = try await plantNetService.identify(imageData: imageData)
            candidates = results
            selectedCandidate = results.first
            showResult = true
            isIdentifying = false
        } catch {
            errorMessage = error.localizedDescription
            isIdentifying = false
        }
    }
}
