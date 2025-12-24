import SwiftUI

struct ChannelCard: View {
    let channel: Channel
    @State private var isHovered = false
    
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(nsColor: .controlBackgroundColor))
                    .shadow(radius: isHovered ? 4 : 1)
                
                if let logo = channel.displayLogoURL {
                    AsyncImage(url: logo) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFit().padding(10)
                        case .failure(_), .empty:
                
                            Image(systemName: "tv").font(.largeTitle).opacity(0.3)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Text(String(channel.name.prefix(1)))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: 100)
            
            Text(channel.name)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
                .truncationMode(.tail)
                .foregroundStyle(isHovered ? .primary : .secondary)
        }
        .frame(height: 130)
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .animation(.spring(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

#Preview {
    ChannelCard(channel: Channel.demo)
        .padding()
        .frame(width: 200, height: 200)
}
