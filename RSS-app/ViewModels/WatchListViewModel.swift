import Foundation
import SwiftData

@MainActor
final class WatchListViewModel: ObservableObject {
    @Published var watches: [Watch] = []
    @Published var showingError: String?

    private let store: DataStore

    init(store: DataStore) {
        self.store = store
        load()
    }

    func load() {
        watches = store.fetchWatches()
    }

    func addWatch(title: String, type: WatchType, url: String?, topic: String?) {
        _ = store.addWatch(title: title, type: type, urlString: url, topic: topic)
        load()
    }

    func delete(at offsets: IndexSet) {
        for index in offsets {
            let watch = watches[index]
            store.deleteWatch(watch)
        }
        load()
    }

    func move(from source: IndexSet, to destination: Int) {
        var mutable = watches
        mutable.move(fromOffsets: source, toOffset: destination)
        store.updateOrder(watches: mutable)
        load()
    }
}
