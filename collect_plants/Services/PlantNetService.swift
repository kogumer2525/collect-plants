import Foundation

class PlantNetService {
    static let shared = PlantNetService()
    private init() {}

    func identify(imageData: Data) async throws -> [PlantCandidate] {
        let apiKey = Constants.plantNetAPIKey
        guard !apiKey.isEmpty, apiKey != "your_api_key_here" else {
            throw PlantNetError.missingAPIKey
        }

        let urlString = "\(Constants.plantNetBaseURL)?api-key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw PlantNetError.invalidURL
        }

        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"organs\"\r\n\r\n".data(using: .utf8)!)
        body.append("auto\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"images\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw PlantNetError.serverError("レスポンスが不正です")
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            // 404 は「植物が見つからなかった」ケース
            if httpResponse.statusCode == 404 {
                throw PlantNetError.notFound
            }
            struct APIError: Decodable { let message: String? }
            let message: String
            if let decoded = try? JSONDecoder().decode(APIError.self, from: data),
               let msg = decoded.message {
                message = "HTTP \(httpResponse.statusCode): \(msg)"
            } else {
                message = "HTTP \(httpResponse.statusCode)"
            }
            throw PlantNetError.serverError(message)
        }

        let result = try JSONDecoder().decode(PlantIdentificationResponse.self, from: data)
        return result.results
    }
}

enum PlantNetError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case notFound
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey: return "APIキーが設定されていません"
        case .invalidURL: return "無効なURLです"
        case .notFound: return "植物を識別できませんでした。別の角度から撮影してみてください"
        case .serverError(let msg): return "サーバーエラー: \(msg)"
        }
    }
}
