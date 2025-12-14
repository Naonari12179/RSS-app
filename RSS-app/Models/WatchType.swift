import Foundation

enum WatchType: String, Codable, CaseIterable, Identifiable {
    case rss
    case website
    case topic

    var id: String { rawValue }

    var title: String {
        switch self {
        case .rss: return "RSS"
        case .website: return "Website"
        case .topic: return "Topic"
        }
    }
}
