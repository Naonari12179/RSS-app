import SwiftUI

struct WatchDetailView: View {
    @StateObject var viewModel: WatchDetailViewModel
    @State private var showingAlert = false

    init(viewModel: WatchDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List(viewModel.items) { item in
            NavigationLink(destination: ItemDetailView(item: item, onToggleRead: { viewModel.toggleRead($0) }, onToggleSaved: { viewModel.toggleSaved($0) })) {
                FeedItemRow(item: item)
            }
        }
        .overlay(Group {
            if viewModel.items.isEmpty {
                ContentUnavailableView("No items", systemImage: "tray")
            }
        })
        .refreshable {
            await viewModel.refresh()
        }
        .navigationTitle("Items")
        .searchable(text: Binding(get: { viewModel.searchText }, set: { viewModel.updateSearch($0) }))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Toggle(isOn: Binding(get: { viewModel.showUnreadOnly }, set: { viewModel.toggleUnreadOnly($0) })) {
                    Image(systemName: viewModel.showUnreadOnly ? "envelope.badge.fill" : "envelope.open")
                }
                .toggleStyle(.button)
            }
        }
        .onChange(of: viewModel.errorMessage) { _ in
            showingAlert = viewModel.errorMessage != nil
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }
    }
}

struct ItemDetailView: View {
    let item: FeedItem
    var onToggleRead: (FeedItem) -> Void
    var onToggleSaved: (FeedItem) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(item.title)
                    .font(.title2)
                    .bold()
                HStack {
                    Text(item.sourceName)
                    if let date = item.publishedAt {
                        Text(date, style: .relative)
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                if let summary = item.summary {
                    Text(summary)
                        .font(.body)
                }

                if let content = item.content {
                    Text(content)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                if let url = item.url {
                    Link(destination: url) {
                        Label("Open in Safari", systemImage: "safari")
                    }
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: { onToggleSaved(item) }) {
                    Image(systemName: item.isSaved ? "bookmark.fill" : "bookmark")
                }
                Button(action: { onToggleRead(item) }) {
                    Image(systemName: item.isRead ? "envelope.open" : "envelope.badge")
                }
            }
        }
    }
}
