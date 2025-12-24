import SwiftUI

struct SettingsView: View {
    @Environment(AppModel.self) var appModel
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("playlist_url") private var playlistURL: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
                .padding()
            
            Text("Configuration de Pulse")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Entrez l'URL de votre liste M3U pour commencer.")
                .foregroundStyle(.secondary)
            
            TextField("https://mon-fournisseur-iptv.com/playlist.m3u", text: $playlistURL)
                .textFieldStyle(.roundedBorder)
                .frame(width: 400)
            
            if let error = appModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.caption)
            }
            
            HStack {
                Button("Annuler") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Button(action: {
                    Task {
                        await appModel.loadPlaylist(from: playlistURL, forceRefresh: true)
                        
                        if appModel.errorMessage == nil && !appModel.channels.isEmpty {
                            dismiss()
                        }
                    }
                }) {
                    if appModel.isLoading {
                        ProgressView().controlSize(.small)
                    } else {
                        Text("Charger la playlist")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(playlistURL.isEmpty)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(40)
        .frame(width: 500)
    }
}

#Preview {
    SettingsView()
        .environment(AppModel())
}
