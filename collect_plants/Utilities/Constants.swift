import Foundation

enum Constants {
    static var plantNetAPIKey: String {
        Bundle.main.infoDictionary?["PLANTNET_API_KEY"] as? String ?? ""
    }

    static let plantNetBaseURL = "https://my-api.plantnet.org/v2/identify/all"
}
