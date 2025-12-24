import SwiftUI

struct StreamPlayer: View {
    let url: URL
    let title: String
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VLCPlayerView(url: url)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding()
                        .shadow(radius: 4)
                    Spacer()
                }
                Spacer()
            }
        }
    }
}
