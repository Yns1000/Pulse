import Foundation

struct PlaylistResult: Sendable {
    let channels: [Channel]
    let categories: [String]
}

actor M3UParserStreamer {
    
    func parseStream(url: URL) async throws -> PlaylistResult {
        var channels: [Channel] = []
        var groupsFound: Set<String> = []
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 300
        config.timeoutIntervalForResource = 600
        let session = URLSession(configuration: config)
        
        let (bytes, response) = try await session.bytes(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        var currentName: String?
        var currentGroup: String = "Autres"
        var currentLogo: String?
        
        let movieKeywords = ["movie", "film", "vod", "cinema"]
        let seriesKeywords = ["series", "série", "season", "saison", "episode"]

        for try await line in bytes.lines {
             let cleanLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
             if cleanLine.isEmpty { continue }
             
             if cleanLine.hasPrefix("#EXTINF:") {
                 let components = cleanLine.components(separatedBy: ",")
                 if let name = components.last {
                     currentName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                 }
                 if let groupRange = cleanLine.range(of: "group-title=\"") {
                     let suffix = cleanLine[groupRange.upperBound...]
                     if let endQuote = suffix.firstIndex(of: "\"") {
                         currentGroup = String(suffix[..<endQuote])
                     }
                 }
                 if let logoRange = cleanLine.range(of: "tvg-logo=\"") {
                     let suffix = cleanLine[logoRange.upperBound...]
                     if let endQuote = suffix.firstIndex(of: "\"") {
                         currentLogo = String(suffix[..<endQuote])
                     }
                 }
             } else if cleanLine.hasPrefix("http") {
                 if let name = currentName {
                     var type: ChannelType = .live
                     let lowerGroup = currentGroup.lowercased()
                     let urlString = cleanLine.lowercased()
                     
                     if urlString.hasSuffix(".mkv") || urlString.hasSuffix(".mp4") || urlString.hasSuffix(".avi") {
                         if lowerGroup.contains("serie") || lowerGroup.contains("saison") { type = .series } else { type = .movie }
                     } else if seriesKeywords.contains(where: lowerGroup.contains) {
                         type = .series
                     } else if movieKeywords.contains(where: lowerGroup.contains) {
                         type = .movie
                     }
                     
                     let channel = await Channel(
                         name: name,
                         url: cleanLine,
                         logoUrl: currentLogo,
                         group: currentGroup,
                         type: type
                     )
                     channels.append(channel)
                     groupsFound.insert(currentGroup)
                 }
                 currentName = nil
                 currentGroup = "Autres"
                 currentLogo = nil
             }
        }
        
        let sortedCategories = groupsFound.sorted()
        return PlaylistResult(channels: channels, categories: sortedCategories)
    }
}
