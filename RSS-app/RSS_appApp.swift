import SwiftUI
import SwiftData
import BackgroundTasks

@main
struct RSS_appApp: App {
    let container: ModelContainer = {
        let schema = Schema([Watch.self, FeedItem.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try! ModelContainer(for: schema, configurations: [configuration])
    }()

    init() {
        BackgroundRefreshManager.shared.register()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(container: container)
        }
        .modelContainer(container)
    }
}
