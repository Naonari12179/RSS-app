import SwiftUI
import SwiftData

struct WatchListView: View {
    @Environment(\.modelContext) private var context
    @ObservedObject var viewModel: WatchListViewModel
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.watches) { watch in
                    NavigationLink(destination: WatchDetailView(viewModel: WatchDetailViewModel(watch: watch, store: DataStore(context: context)))) {
                        VStack(alignment: .leading) {
                            Text(watch.title)
                            Text(watch.type.title)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: viewModel.delete)
                .onMove(perform: viewModel.move)
            }
            .navigationTitle("Watchlist")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { EditButton() }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAdd = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddWatchView { title, type, url, topic in
                    viewModel.addWatch(title: title, type: type, url: url, topic: topic)
                }
            }
        }
    }
}

struct AddWatchView: View {
    var onAdd: (String, WatchType, String?, String?) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var type: WatchType = .rss
    @State private var url: String = ""
    @State private var topic: String = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                Picker("Type", selection: $type) {
                    ForEach(WatchType.allCases) { t in
                        Text(t.title).tag(t)
                    }
                }
                .pickerStyle(.segmented)

                if type != .topic {
                    TextField("URL", text: $url)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                } else {
                    TextField("Keyword / Ticker", text: $topic)
                }
            }
            .navigationTitle("Add Watch")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onAdd(title, type, url.isEmpty ? nil : url, topic.isEmpty ? nil : topic)
                        dismiss()
                    }
                    .disabled(title.isEmpty || (type != .topic && url.isEmpty))
                }
            }
        }
    }
}
