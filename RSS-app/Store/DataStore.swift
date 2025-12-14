import Foundation
import SwiftData

@MainActor
final class DataStore {
    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchWatches() -> [Watch] {
        let descriptor = FetchDescriptor<Watch>(sortBy: [SortDescriptor(\Watch.order)])
        return (try? context.fetch(descriptor)) ?? []
    }

    func addWatch(title: String, type: WatchType, urlString: String?, topic: String?) -> Watch {
        let newWatch = Watch(title: title, type: type, urlString: urlString, topic: topic, order: fetchWatches().count)
        context.insert(newWatch)
        return newWatch
    }

    func deleteWatch(_ watch: Watch) {
        context.delete(watch)
    }

    func updateOrder(watches: [Watch]) {
        for (index, watch) in watches.enumerated() {
            watch.order = index
        }
    }

    func fetchFeedItems(for watch: Watch? = nil, searchText: String? = nil, unreadOnly: Bool = false) -> [FeedItem] {
        let descriptor = FetchDescriptor<FeedItem>(sortBy: [SortDescriptor(\FeedItem.isRead, order: .forward), SortDescriptor(\FeedItem.fetchedAt, order: .reverse)])
        var results = (try? context.fetch(descriptor)) ?? []

        if let watch {
            switch watch.type {
            case .rss, .website:
                results = results.filter { $0.watchId == watch.id }
            case .topic:
                if let keyword = watch.topic?.lowercased(), !keyword.isEmpty {
                    results = results.filter { item in
                        item.title.lowercased().contains(keyword) || (item.summary?.lowercased().contains(keyword) ?? false)
                    }
                }
            }
        }

        if unreadOnly {
            results = results.filter { !$0.isRead }
        }

        if let text = searchText, !text.isEmpty {
            let lower = text.lowercased()
            results = results.filter { item in
                item.title.lowercased().contains(lower) || (item.summary?.lowercased().contains(lower) ?? false)
            }
        }

        return results
    }

    func upsertFeedItems(_ items: [FeedItem]) {
        guard !items.isEmpty else { return }
        let urls = items.compactMap { URL(string: $0.urlString)?.absoluteString }
        let existingDescriptor = FetchDescriptor<FeedItem>(predicate: #Predicate { urls.contains($0.urlString) })
        let existing = (try? context.fetch(existingDescriptor)) ?? []
        let existingURLs = Set(existing.map { $0.urlString })

        for item in items where !existingURLs.contains(item.urlString) {
            context.insert(item)
        }
    }

    func toggleRead(_ item: FeedItem) {
        item.isRead.toggle()
    }

    func toggleSaved(_ item: FeedItem) {
        item.isSaved.toggle()
    }
}
