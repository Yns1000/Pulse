import SwiftUI

struct ChannelGrid: View {
    let channels: [Channel]
    
    @State private var selectedChannel: Channel?
    
    let columns = [
        GridItem(.adaptive(minimum: 140, maximum: 180), spacing: 20)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(channels) { channel in
                    Button {
                        selectedChannel = channel
                    } label: {
                        ChannelCard(channel: channel)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .sheet(item: $selectedChannel) { channel in
            if let validURL = channel.playableURL {
                StreamPlayer(url: validURL, title: channel.name)
                    .frame(minWidth: 800, minHeight: 450)
            } else {
                ContentUnavailableView("Lien invalide", systemImage: "exclamationmark.triangle")
            }
        }
    }
}
