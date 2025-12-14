import Foundation
import SwiftData

struct FeedItemDTO: Codable, Identifiable {
    let id: UUID
    let title: String
    let url: URL
    let sourceName: String
    let publishedAt: Date?
    let fetchedAt: Date
    let summary: String?
    let content: String?
    let isRead: Bool
    let isSaved: Bool
    let tags: [String]
    let watchId: UUID
}

@Model
final class FeedItem: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var urlString: String
    var sourceName: String
    var publishedAt: Date?
    var fetchedAt: Date
    var summary: String?
    var content: String?
    var isRead: Bool
    var isSaved: Bool
    var tags: [String]
    var watchId: UUID

    init(id: UUID = UUID(), title: String, url: URL, sourceName: String, publishedAt: Date?, fetchedAt: Date = .now, summary: String? = nil, content: String? = nil, isRead: Bool = false, isSaved: Bool = false, tags: [String] = [], watchId: UUID) {
        self.id = id
        self.title = title
        self.urlString = url.absoluteString
        self.sourceName = sourceName
        self.publishedAt = publishedAt
        self.fetchedAt = fetchedAt
        self.summary = summary
        self.content = content
        self.isRead = isRead
        self.isSaved = isSaved
        self.tags = tags
        self.watchId = watchId
    }

    var url: URL? { URL(string: urlString) }

    func toDTO() -> FeedItemDTO {
        FeedItemDTO(id: id, title: title, url: URL(string: urlString) ?? URL(string: "https://example.com")!, sourceName: sourceName, publishedAt: publishedAt, fetchedAt: fetchedAt, summary: summary, content: content, isRead: isRead, isSaved: isSaved, tags: tags, watchId: watchId)
    }
}
