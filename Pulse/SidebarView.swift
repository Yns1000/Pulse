import SwiftUI

struct SidebarView: View {
    @Environment(AppModel.self) var appModel
    @Binding var selection: String?
    
    var body: some View {
        List(selection: $selection) {
            Section {
                Picker("Mode", selection: Binding(
                    get: { appModel.selectedTab },
                    set: { newTab in
                        appModel.updateTab(to: newTab)
                        selection = "all"
                    }
                )) {
                    ForEach(ChannelType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 8)
            }
            
            Section("Ma Bibliothèque") {
                Label("Tout voir", systemImage: "square.grid.2x2")
                    .tag("all")
            }
            
            Section("Catégories (\(appModel.visibleCategories.count))") {
                ForEach(appModel.visibleCategories, id: \.self) { category in
                    Label(category, systemImage: iconForCategory(category))
                        .tag(category)
                }
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 220)
    }
    
    func iconForCategory(_ category: String) -> String {
        let low = category.lowercased()
        if low.contains("sport") { return "sportscourt" }
        if low.contains("news") || low.contains("info") { return "newspaper" }
        if low.contains("cin") || low.contains("film") { return "film" }
        if low.contains("kid") || low.contains("enfant") { return "figure.and.child.holdinghands" }
        if low.contains("doc") { return "text.book.closed" }
        if low.contains("music") { return "music.note" }
        return "folder"
    }
}
