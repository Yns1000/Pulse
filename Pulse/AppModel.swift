import Foundation
import Observation

@Observable
class AppModel {
    var channels: [Channel] = []
    var allCategories: [String] = []
    var visibleCategories: [String] = []
    var isLoading = false
    var errorMessage: String? = nil
    var selectedTab: ChannelType = .live
    var lastUpdateDate: Date? = nil
    
    private let parser = M3UParserStreamer()
    private let storage = PlaylistStorage()
    
    func loadPlaylist(from urlString: String, forceRefresh: Bool = false) async {
        guard let url = URL(string: urlString) else { return }
        
        self.errorMessage = nil
        
        if !forceRefresh {
            do {
                if let cached = try await storage.load() {
                    await MainActor.run {
                        self.channels = cached.channels
                        self.allCategories = cached.categories
                        self.lastUpdateDate = cached.lastUpdate
                        self.updateVisibleCategories()
                    }
                    return
                }
            } catch {
                print("⚠️ Impossible de lire le cache, téléchargement nécessaire.")
            }
        }
        
        await fetchAndSave(url: url)
    }
    
    private func fetchAndSave(url: URL) async {
        self.isLoading = true
        self.channels = []
        
        do {
            let result = try await parser.parseStream(url: url)
            
            try await storage.save(channels: result.channels, categories: result.categories)
            
            await MainActor.run {
                self.channels = result.channels
                self.allCategories = result.categories
                self.lastUpdateDate = Date()
                self.updateVisibleCategories()
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Erreur : \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func updateVisibleCategories() {
        let activeGroups = Set(channels.filter { $0.type == selectedTab }.map { $0.group })
        self.visibleCategories = activeGroups.sorted()
    }
    
    func updateTab(to type: ChannelType) {
        self.selectedTab = type
        updateVisibleCategories()
    }
    
    func channels(for category: String?) -> [Channel] {
        let typeFiltered = channels.filter { $0.type == selectedTab }
        guard let category = category, category != "all" else {
            return typeFiltered
        }
        return typeFiltered.filter { $0.group == category }
    }
}
