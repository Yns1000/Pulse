import SwiftUI

struct ContentView: View {
    @Environment(AppModel.self) var appModel
    @State private var selection: String? = "all"
    @AppStorage("playlist_url") private var playlistURL: String = ""
    @State private var showSettings = false
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selection)
        } detail: {
            Group {
                if appModel.isLoading {
                    ProgressView("Mise à jour de la bibliothèque...")
                }
                else if !appModel.channels.isEmpty {
                    if let selection {
                        let displayedChannels = appModel.channels(for: selection)
                        ChannelGrid(channels: displayedChannels)
                            .navigationTitle(selection.capitalized)
                    } else {
                        Text("Sélectionnez une catégorie")
                    }
                }
                else {
                    ContentUnavailableView("Aucune playlist", systemImage: "tv.slash")
                }
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: { showSettings = true }) {
                        Label("Réglages", systemImage: "gear")
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        Task {
                            await appModel.loadPlaylist(from: playlistURL, forceRefresh: true)
                        }
                    }) {
                        Label("Mettre à jour", systemImage: "arrow.clockwise")
                    }
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onAppear {
            if playlistURL.isEmpty {
                showSettings = true
            } else {
                Task {
                    await appModel.loadPlaylist(from: playlistURL)
                }
            }
        }
    }
}
