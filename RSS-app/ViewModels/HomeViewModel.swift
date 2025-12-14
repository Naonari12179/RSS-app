import Foundation
import SwiftData

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var items: [FeedItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let store: DataStore
    private let service: WatchService

    init(store: DataStore, service: WatchService = WatchService()) {
        self.store = store
        self.service = service
    }

    func load() {
        items = store.fetchFeedItems()
    }

    func toggleRead(_ item: FeedItem) {
        store.toggleRead(item)
        load()
    }

    func toggleSaved(_ item: FeedItem) {
        store.toggleSaved(item)
        load()
    }

    func refreshAll() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let watches = store.fetchWatches()
            for watch in watches where watch.type != .topic {
                let result = try await service.refresh(watch: watch)
                store.upsertFeedItems(result.newItems)
                watch.lastETag = result.updatedWatch.lastETag
                watch.lastModified = result.updatedWatch.lastModified
                watch.lastContentHash = result.updatedWatch.lastContentHash
                watch.lastFetchedAt = result.updatedWatch.lastFetchedAt
            }
            load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
