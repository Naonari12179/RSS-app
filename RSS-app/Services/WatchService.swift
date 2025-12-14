import Foundation
import CryptoKit

struct WatchUpdateResult {
    let newItems: [FeedItem]
    let updatedWatch: Watch
}

enum WatchServiceError: LocalizedError {
    case invalidURL
    case networkFailure
    case parsingFailure

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .networkFailure: return "Network request failed"
        case .parsingFailure: return "Failed to parse response"
        }
    }
}

final class WatchService {
    private let session: URLSession
    private let rssParser: RSSParser

    init(session: URLSession = .shared, rssParser: RSSParser = RSSParser()) {
        self.session = session
        self.rssParser = rssParser
    }

    func refresh(watch: Watch) async throws -> WatchUpdateResult {
        switch watch.type {
        case .rss:
            return try await fetchRSS(watch: watch)
        case .website:
            return try await monitorWebsite(watch: watch)
        case .topic:
            return WatchUpdateResult(newItems: [], updatedWatch: watch)
        }
    }

    private func fetchRSS(watch: Watch) async throws -> WatchUpdateResult {
        guard let url = watch.url else { throw WatchServiceError.invalidURL }
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else { throw WatchServiceError.networkFailure }
        let parsed = rssParser.parse(data: data, watchId: watch.id, sourceName: watch.title)
        return WatchUpdateResult(newItems: parsed, updatedWatch: watch)
    }

    private func monitorWebsite(watch: Watch) async throws -> WatchUpdateResult {
        guard let url = watch.url else { throw WatchServiceError.invalidURL }
        var request = URLRequest(url: url)
        if let etag = watch.lastETag { request.addValue(etag, forHTTPHeaderField: "If-None-Match") }
        if let modified = watch.lastModified { request.addValue(modified, forHTTPHeaderField: "If-Modified-Since") }

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw WatchServiceError.networkFailure }

        if http.statusCode == 304 {
            return WatchUpdateResult(newItems: [], updatedWatch: watch)
        }

        guard 200..<300 ~= http.statusCode else { throw WatchServiceError.networkFailure }

        let bodyHash = sha256(data: data)
        var mutatedWatch = watch
        mutatedWatch.lastETag = http.value(forHTTPHeaderField: "Etag") ?? watch.lastETag
        mutatedWatch.lastModified = http.value(forHTTPHeaderField: "Last-Modified") ?? watch.lastModified
        mutatedWatch.lastContentHash = bodyHash
        mutatedWatch.lastFetchedAt = .now

        var newItems: [FeedItem] = []
        if watch.lastContentHash == nil || watch.lastContentHash != bodyHash {
            let title = "Updated: \(url.host ?? url.absoluteString)"
            let item = FeedItem(title: title, url: url, sourceName: watch.title, publishedAt: Date(), summary: "Content changed", watchId: watch.id)
            newItems = [item]
        }

        return WatchUpdateResult(newItems: newItems, updatedWatch: mutatedWatch)
    }

    private func sha256(data: Data) -> String {
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
