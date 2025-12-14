import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var showingAlert = false

    var body: some View {
        NavigationStack {
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
                await viewModel.refreshAll()
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isLoading {
                        ProgressView()
                    }
                }
            }
            .task {
                viewModel.load()
            }
            .onChange(of: viewModel.errorMessage) { _ in
                showingAlert = viewModel.errorMessage != nil
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK", role: .cancel) {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "Unknown error")
            }
        }
    }
}

struct FeedItemRow: View {
    let item: FeedItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(item.title)
                    .font(.headline)
                    .lineLimit(2)
                if !item.isRead {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                }
            }
            Text(item.sourceName)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if let date = item.publishedAt {
                Text(date, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}
