import Foundation

enum ChannelType: String, Codable, CaseIterable, Sendable {
    case live = "TV Direct"
    case movie = "Films"
    case series = "Séries"
}

struct Channel: Identifiable, Hashable, Sendable, Codable {
    let id: UUID
    let name: String
    let url: String
    let logoUrl: String?
    let group: String
    let type: ChannelType
    
    init(id: UUID = UUID(), name: String, url: String, logoUrl: String?, group: String, type: ChannelType) {
        self.id = id
        self.name = name
        self.url = url
        self.logoUrl = logoUrl
        self.group = group
        self.type = type
    }
    
    var playableURL: URL? {
        return URL(string: url.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    var displayLogoURL: URL? {
        guard let logoUrl else { return nil }
        return URL(string: logoUrl)
    }

    static let demo = Channel(
        name: "TF1 Demo",
        url: "http://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8",
        logoUrl: "https://upload.wikimedia.org/wikipedia/fr/thumb/e/e2/TF1_logo_2013.svg/1200px-TF1_logo_2013.svg.png",
        group: "France",
        type: .live
    )
}
