import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            LazyVStack(spacing: 1) {
                ForEach(0..<viewModel.posts.count, id: \.self) { index in
                    PostView(post: $viewModel.posts[index], viewModel: viewModel)
                        .onAppear {
                            if index == viewModel.posts.count - 1 {
                                viewModel.loadMoreContent()
                            }
                        }
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    ContentView()
}
