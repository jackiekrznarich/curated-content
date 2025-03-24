import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel(postsPerPage: 20)
    @State private var currentPage = 0
    @State private var postsPerPage = 20
    @State private var hasMoreContent = true
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            LazyVStack(spacing: 1) {
                ForEach(paginatedPosts, id: \.id) { post in
                    PostView(post: binding(for: post), viewModel: viewModel)
                }
                if hasMoreContent {
                    Button(action: {
                        loadNextPage()
                    }) {
                        Text("Load More")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding(.vertical)
                } else {
                    Text("No more posts")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            viewModel.loadInitialPosts()
        }
    }
    var paginatedPosts: [Post] {
        let endIndex = min((currentPage + 1) * postsPerPage, viewModel.posts.count)
        return Array(viewModel.posts[0..<endIndex])
    }
        
    func loadNextPage() {
        // Check if we need to load more data
        let nextPageStart = (currentPage + 1) * postsPerPage
        
        if nextPageStart >= viewModel.posts.count {
            // Need to fetch more posts
            viewModel.loadMoreContent(postsPerPage)
            
            // You can add logic here to determine if there's no more content
            // For example, if loadMoreContent() returns fewer than postsPerPage items
            // For now, we'll assume there's always more content
        }
        currentPage += 1
    }
    private func binding(for post: Post) -> Binding<Post> {
       guard let index = viewModel.posts.firstIndex(where: { $0.id == post.id }) else {
           fatalError("Post not found")
       }
       return $viewModel.posts[index]
   }
}

#Preview {
    ContentView()
}
