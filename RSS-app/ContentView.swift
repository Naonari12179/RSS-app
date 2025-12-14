import SwiftUI
import SwiftData

struct ContentView: View {
    let container: ModelContainer
    @StateObject private var homeViewModel: HomeViewModel
    @StateObject private var watchListViewModel: WatchListViewModel

    init(container: ModelContainer) {
        self.container = container
        let store = DataStore(context: container.mainContext)
        _homeViewModel = StateObject(wrappedValue: HomeViewModel(store: store))
        _watchListViewModel = StateObject(wrappedValue: WatchListViewModel(store: store))
    }

    var body: some View {
        TabView {
            HomeView(viewModel: homeViewModel)
                .tabItem {
                    Label("Home", systemImage: "list.bullet")
                }
            WatchListView(viewModel: watchListViewModel)
                .tabItem {
                    Label("Watchlist", systemImage: "eye")
                }
        }
        .task {
            BackgroundRefreshManager.shared.schedule()
        }
    }
}

#Preview {
    ContentView(container: try! ModelContainer(for: [Watch.self, FeedItem.self]))
}
