import Foundation

struct CachedPlaylist: Codable {
    let channels: [Channel]
    let categories: [String]
    let lastUpdate: Date
}

actor PlaylistStorage {
    
    private var fileURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("playlist_cache.json")
    }
    
    func save(channels: [Channel], categories: [String]) async throws {
        let data = CachedPlaylist(channels: channels, categories: categories, lastUpdate: Date())
        let encoded = try JSONEncoder().encode(data)
        try encoded.write(to: fileURL)
        print("💾 Playlist sauvegardée : \(channels.count) chaînes.")
    }
    
    func load() async throws -> CachedPlaylist? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        
        let data = try Data(contentsOf: fileURL)
        let decoded = try JSONDecoder().decode(CachedPlaylist.self, from: data)
        print("📂 Playlist chargée depuis le cache : \(decoded.channels.count) chaînes.")
        return decoded
    }
    
    func clear() throws {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
    }
}
