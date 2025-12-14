import Foundation
import SwiftData

@Model
final class Watch: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var type: WatchType
    var urlString: String?
    var topic: String?
    var createdAt: Date
    var order: Int
    var lastETag: String?
    var lastModified: String?
    var lastContentHash: String?
    var lastFetchedAt: Date?

    init(id: UUID = UUID(), title: String, type: WatchType, urlString: String? = nil, topic: String? = nil, createdAt: Date = .now, order: Int = 0, lastETag: String? = nil, lastModified: String? = nil, lastContentHash: String? = nil, lastFetchedAt: Date? = nil) {
        self.id = id
        self.title = title
        self.type = type
        self.urlString = urlString
        self.topic = topic
        self.createdAt = createdAt
        self.order = order
        self.lastETag = lastETag
        self.lastModified = lastModified
        self.lastContentHash = lastContentHash
        self.lastFetchedAt = lastFetchedAt
    }

    var url: URL? {
        guard let urlString, let url = URL(string: urlString) else { return nil }
        return url
    }
}
