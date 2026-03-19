import Foundation

struct MistralPlantInfo: Sendable {
    let japaneseName: String
    let description: String
}

struct MistralMessage: Codable, Sendable {
    let role: String
    let content: String
}

struct MistralRequest: Codable, Sendable {
    let model: String
    let messages: [MistralMessage]
    let max_tokens: Int
    let temperature: Double
}

struct MistralResponse: Codable, Sendable {
    let choices: [Choice]

    struct Choice: Codable, Sendable {
        let message: MistralMessage
    }
}

struct MistralJSONResponse: Codable, Sendable {
    let japaneseName: String
    let description: String
}

enum MistralError: LocalizedError {
    case invalidURL
    case invalidAPIKey
    case networkError(String)
    case decodeError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "無効なURLです"
        case .invalidAPIKey:
            return "Mistral APIキーが設定されていません"
        case .networkError(let msg):
            return "通信エラー: \(msg)"
        case .decodeError(let msg):
            return "レスポンス解析エラー: \(msg)"
        }
    }
}

class MistralService {
    static let shared = MistralService()
    private init() {}

    private var apiKey: String {
        guard let key = Bundle.main.infoDictionary?["MISTRAL_API_KEY"] as? String, !key.isEmpty else {
            return ""
        }
        return key
    }

    func fetchPlantInfo(scientificName: String) async throws -> MistralPlantInfo {
        guard !apiKey.isEmpty else {
            print("[Mistral] APIキーが設定されていません")
            throw MistralError.invalidAPIKey
        }

        print("[Mistral] 学名 '\(scientificName)' で AI に問い合わせ中...")

        let prompt = """
        あなたは植物学の専門家です。

        与えられた学名（Scientific Name）の植物について、以下の情報を日本語で提供してください：
        1. 日本語名（一般的な呼称。不明な場合は「不明」と記載）
        2. 説明（その植物の特徴や用途など、100字程度）

        学名: \(scientificName)

        JSONフォーマットで以下の形式で返してください：
        {
            "japaneseName": "日本語名",
            "description": "説明文"
        }

        JSONのみを返し、他の説明は不要です。
        """

        let message = MistralMessage(role: "user", content: prompt)
        let request = MistralRequest(
            model: "mistral-small-latest",
            messages: [message],
            max_tokens: 512,
            temperature: 0.3
        )

        let url = URL(string: "https://api.mistral.ai/v1/chat/completions")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let encoder = JSONEncoder()
        urlRequest.httpBody = try encoder.encode(request)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw MistralError.networkError("HTTPレスポンスが無効です")
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "不明なエラー"
            throw MistralError.networkError("ステータスコード: \(httpResponse.statusCode) - \(errorMessage)")
        }

        let mistralResponse = try JSONDecoder().decode(MistralResponse.self, from: data)
        guard let firstChoice = mistralResponse.choices.first else {
            print("[Mistral] チョイスが空です")
            throw MistralError.decodeError("チョイスが空です")
        }

        let responseContent = firstChoice.message.content
        print("[Mistral] レスポンス: \(responseContent)")

        // JSONを抽出して解析
        var jsonString = responseContent
        
        // Markdown のコードブロック形式を処理 (```json ... ``` の形式)
        if jsonString.contains("```json") {
            if let startRange = jsonString.range(of: "```json") {
                let afterStart = jsonString.index(startRange.upperBound, offsetBy: 0)
                if let endRange = jsonString.range(of: "```", range: afterStart..<jsonString.endIndex) {
                    jsonString = String(jsonString[afterStart..<endRange.lowerBound])
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        } else if jsonString.contains("```") {
            // ``` で囲まれている場合
            if let startRange = jsonString.range(of: "```") {
                let afterStart = jsonString.index(startRange.upperBound, offsetBy: 0)
                if let endRange = jsonString.range(of: "```", range: afterStart..<jsonString.endIndex) {
                    jsonString = String(jsonString[afterStart..<endRange.lowerBound])
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        }
        
        print("[Mistral] 抽出後のJSON: \(jsonString)")
        
        if let jsonData = jsonString.data(using: .utf8) {
            let decoder = JSONDecoder()
            if let jsonResponse = try? decoder.decode(MistralJSONResponse.self, from: jsonData) {
                print("[Mistral] 解析成功 - 日本語名: \(jsonResponse.japaneseName)")
                return MistralPlantInfo(
                    japaneseName: jsonResponse.japaneseName.isEmpty ? "不明" : jsonResponse.japaneseName,
                    description: jsonResponse.description.isEmpty ? "情報を取得できませんでした" : jsonResponse.description
                )
            }
        }

        print("[Mistral] JSONパース失敗")
        throw MistralError.decodeError("JSONレスポンスのパースに失敗しました")
    }
}
