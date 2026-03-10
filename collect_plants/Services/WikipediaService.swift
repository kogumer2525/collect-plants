import Foundation

struct WikipediaPlantInfo: Sendable {
    let japaneseName: String
    let description: String
}

struct OpenSearchResponse: Codable, Sendable {
    let query: String
    let results: [String]
    let descriptions: [String]
    let urls: [String]

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        query = try container.decode(String.self)
        results = try container.decode([String].self)
        descriptions = try container.decode([String].self)
        urls = try container.decode([String].self)
    }
}

struct WikipediaSearchResponse: Decodable, Sendable {
    let query: Query

    struct Query: Decodable, Sendable {
        let search: [SearchItem]
    }

    struct SearchItem: Decodable, Sendable {
        let title: String
    }
}

struct WikipediaLangLinksResponse: Decodable, Sendable {
    let query: Query?

    struct Query: Decodable, Sendable {
        let pages: [String: Page]
    }

    struct Page: Decodable, Sendable {
        let langlinks: [LangLink]?
    }

    struct LangLink: Decodable, Sendable {
        let lang: String
        let title: String

        enum CodingKeys: String, CodingKey {
            case lang
            case title = "*"
        }
    }
}

struct WikipediaSummary: Codable, Sendable {
    let title: String
    let extract: String
}

enum WikipediaError: LocalizedError {
    case invalidURL
    case notFound
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "無効なURLです"
        case .notFound: return "Wikipedia記事が見つかりませんでした"
        case .networkError(let msg): return "通信エラー: \(msg)"
        }
    }
}

class WikipediaService {
    static let shared = WikipediaService()
    private init() {}

    func fetchPlantInfo(scientificName: String) async throws -> WikipediaPlantInfo {
        // Step 1: Wikipedia apiで日本語名を取得
        let japaneseName = try await fetchJapaneseName(scientificName: scientificName)

        // Step 2: Wikipedia summary APIで解説文を取得
        let description = try await fetchDescription(japaneseName: japaneseName)

        return WikipediaPlantInfo(
            japaneseName: japaneseName,
            description: description
        )
    }

    private func fetchJapaneseName(scientificName: String) async throws -> String {
        // 1) 学名で英語Wikipediaを検索して正確な英語記事を取得
        if let enTitle = try await fetchEnglishTitleByOpenSearch(query: scientificName), !enTitle.isEmpty {
            // 2) その英語記事から日本語のlanglinksを取得 → 最も確実
            if let jaTitle = try await fetchJapaneseNameByLangLinks(scientificName: enTitle), !jaTitle.isEmpty {
                return jaTitle
            }
        }

        // langlinksで見つからない場合は、日本語Wikipediaの検索はスキップして「日本語名不明」を返す
        // 無関係な日本語記事がヒットするのを防ぐため
        return "日本語名不明"
    }

    private func fetchEnglishTitleByOpenSearch(query: String) async throws -> String? {
        var components = URLComponents(string: "https://en.wikipedia.org/w/api.php")
        components?.queryItems = [
            URLQueryItem(name: "action", value: "opensearch"),
            URLQueryItem(name: "search", value: query),
            URLQueryItem(name: "limit", value: "1"),
            URLQueryItem(name: "namespace", value: "0"),
            URLQueryItem(name: "format", value: "json")
        ]
        guard let url = components?.url else {
            throw WikipediaError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            return nil
        }

        let decoded = try JSONDecoder().decode(OpenSearchResponse.self, from: data)
        return decoded.results.first
    }

    private func fetchJapaneseNameByOpenSearch(scientificName: String) async throws -> String? {
        var components = URLComponents(string: "https://ja.wikipedia.org/w/api.php")
        components?.queryItems = [
            URLQueryItem(name: "action", value: "opensearch"),
            URLQueryItem(name: "search", value: scientificName),
            URLQueryItem(name: "limit", value: "1"),
            URLQueryItem(name: "namespace", value: "0"),
            URLQueryItem(name: "format", value: "json")
        ]
        guard let url = components?.url else {
            throw WikipediaError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            return nil
        }

        let decoded = try JSONDecoder().decode(OpenSearchResponse.self, from: data)
        return decoded.results.first
    }

    private func fetchJapaneseNameByJaSearch(scientificName: String) async throws -> String? {
        var components = URLComponents(string: "https://ja.wikipedia.org/w/api.php")
        components?.queryItems = [
            URLQueryItem(name: "action", value: "query"),
            URLQueryItem(name: "list", value: "search"),
            URLQueryItem(name: "srsearch", value: scientificName),
            URLQueryItem(name: "srlimit", value: "1"),
            URLQueryItem(name: "format", value: "json")
        ]
        guard let url = components?.url else {
            throw WikipediaError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            return nil
        }

        let decoded = try JSONDecoder().decode(WikipediaSearchResponse.self, from: data)
        return decoded.query.search.first?.title
    }

    private func fetchJapaneseNameByLangLinks(scientificName: String) async throws -> String? {
        var components = URLComponents(string: "https://en.wikipedia.org/w/api.php")
        components?.queryItems = [
            URLQueryItem(name: "action", value: "query"),
            URLQueryItem(name: "prop", value: "langlinks"),
            URLQueryItem(name: "titles", value: scientificName),
            URLQueryItem(name: "lllang", value: "ja"),
            URLQueryItem(name: "format", value: "json")
        ]
        guard let url = components?.url else {
            throw WikipediaError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            return nil
        }

        let decoded = try JSONDecoder().decode(WikipediaLangLinksResponse.self, from: data)
        guard let pages = decoded.query?.pages else { return nil }
        for (_, page) in pages {
            if let first = page.langlinks?.first(where: { $0.lang == "ja" }) {
                return first.title
            }
        }
        return nil
    }

    private func fetchDescription(japaneseName: String) async throws -> String {
        guard japaneseName != "日本語名不明" else {
            return "情報を取得できませんでした"
        }

        let encoded = japaneseName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? japaneseName
        let urlString = "https://ja.wikipedia.org/api/rest_v1/page/summary/\(encoded)"
        guard let url = URL(string: urlString) else {
            return "情報を取得できませんでした"
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                return "情報を取得できませんでした"
            }

            let summary = try JSONDecoder().decode(WikipediaSummary.self, from: data)
            let extract = summary.extract.trimmingCharacters(in: .whitespacesAndNewlines)
            return extract.isEmpty ? "情報を取得できませんでした" : extract
        } catch {
            return "情報を取得できませんでした"
        }
    }
}

