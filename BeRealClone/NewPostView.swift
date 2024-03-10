//
//  NewPostView.swift
//  BeRealClone
//
//  Created by Elias Woldie on 3/8/24.
//

import SwiftUI
import Parse

struct Post: Identifiable {
    var id: String
    var image: UIImage?
    var caption: String
    var author: String
    var location: String?
    var timestamp: Date?
    
}


struct PostView: View {
    var post: Post
    
    var body: some View {
        VStack(alignment: .leading) {
            if let image = post.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
            Text(post.caption)
                .font(.caption)
                .foregroundColor(.gray)
            Text("Posted by \(post.author)")
                .font(.caption)
                .foregroundColor(.secondary)
            if let location = post.location {
                Text(location)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let timestamp = post.timestamp {
                Text(timestamp, style: .date) // Format the date as needed
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()

    }
}


struct NewPostView: View {
    @State private var posts: [Post] = []
    @State private var isUploading = false
    @Binding var isLoggedIn: Bool
    @State private var showingUploadPostView = false

    var body: some View {
        VStack {
            // Header
            HStack {
                Spacer()
                Text("BeReal.")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                Spacer()
                Button(action: logout) {
                    Text("Logout")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color.black)
            
            // Post a Photo Button
            Button(action: {
                showingUploadPostView = true // Present the UploadPostView
            }) {
                Text("Post a Photo")
                    .foregroundColor(.white)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
            .background(Color.black)
            
            // List of posts
            List(posts) { post in
                PostView(post: post)
                    .listRowBackground(Color.black)
            }
            .refreshable {
                fetchPosts()
            }
            .task {
                fetchPosts()
            }
            .background(Color.black)

            
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .sheet(isPresented: $showingUploadPostView) {
                UploadPostView(isPresented: $showingUploadPostView, didCompleteUpload: {
                    self.fetchPosts() // This will refresh the posts list
                })
            }
        }
        
    }
    func fetchPosts() {
        let query = PFQuery(className: "Post")
        query.includeKey("author")
        query.order(byDescending: "createdAt")

        query.findObjectsInBackground { (objects, error) in
            if let error = error {
                print("Error fetching posts: \(error.localizedDescription)")
            } else if let objects = objects {
                var fetchedPosts: [Post] = []

                for object in objects {
                    if let author = object["author"] as? PFUser,
                       let file = object["image"] as? PFFileObject,
                       let caption = object["caption"] as? String {
                        let postId = object.objectId ?? "unknown"
                        let authorName = author.username ?? "Anonymous"
                        let location = object["location"] as? String // Retrieve location
                        let timestamp = object.createdAt // Retrieve timestamp (Date)

                        file.getDataInBackground { (data, error) in
                            if let data = data, let image = UIImage(data: data) {
                                let post = Post(id: postId, image: image, caption: caption, author: authorName, location: location, timestamp: timestamp)
                                fetchedPosts.append(post)

                                // Update the posts array on the main thread
                                DispatchQueue.main.async {
                                    self.posts = fetchedPosts
                                }
                            } else if let error = error {
                                print("Error fetching image for post: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }
        }
    }

    
    
    
    
    func logout() {
        PFUser.logOutInBackground { (error) in
            if let error = error {
                print("Error logging out: \(error.localizedDescription)")
            } else {
                print("Successfully logged out")
                DispatchQueue.main.async {
                    self.isLoggedIn = false
                }
            }
        }
        
    }
    
    
    struct NewPostView_Previews: PreviewProvider {
        @State static var isLoggedIn = true
        
        static var previews: some View {
            NewPostView(isLoggedIn: $isLoggedIn)
        }
    }
}
