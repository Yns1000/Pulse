import SwiftUI
import VLCKit

struct VLCPlayerView: NSViewRepresentable {
    let url: URL
    
    func makeNSView(context: Context) -> VLCVideoView {
        let videoView = VLCVideoView()
        
        let player = VLCMediaPlayer()
        player.drawable = videoView
        
        let media = VLCMedia(url: url)
        
        media.addOptions([
            "network-caching": 1500,
            "clock-jitter": 0,
            "clock-synchro": 0
        ])
        
        player.media = media
        player.play()
        
        context.coordinator.player = player
        return videoView
    }
    
    func updateNSView(_ nsView: VLCVideoView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var player: VLCMediaPlayer?
    }
}
