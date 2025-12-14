import Foundation
import SwiftData

@MainActor
final class WatchDetailViewModel: ObservableObject {
    @Published var items: [FeedItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText: String = ""
    @Published var showUnreadOnly = false

    private let store: DataStore
    private let service: WatchService
    private var watch: Watch

    init(watch: Watch, store: DataStore, service: WatchService = WatchService()) {
        self.watch = watch
        self.store = store
        self.service = service
        load()
    }

    func load() {
        items = store.fetchFeedItems(for: watch, searchText: searchText, unreadOnly: showUnreadOnly)
    }

    func refresh() async {
        guard watch.type != .topic else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let result = try await service.refresh(watch: watch)
            store.upsertFeedItems(result.newItems)
            watch.lastETag = result.updatedWatch.lastETag
            watch.lastModified = result.updatedWatch.lastModified
            watch.lastContentHash = result.updatedWatch.lastContentHash
            watch.lastFetchedAt = result.updatedWatch.lastFetchedAt
            load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleRead(_ item: FeedItem) {
        store.toggleRead(item)
        load()
    }

    func toggleSaved(_ item: FeedItem) {
        store.toggleSaved(item)
        load()
    }

    func updateSearch(_ text: String) {
        searchText = text
        load()
    }

    func toggleUnreadOnly(_ flag: Bool) {
        showUnreadOnly = flag
        load()
    }
}
