//
//  NewPostView.swift
//  BeRealClone
//
//  Created by Elias Woldie on 3/8/24.
//

import SwiftUI
import Parse

struct Post: Identifiable {
    var id: String  // Parse object ID
    var image: UIImage?
    var caption: String
    var author: String
    
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
        }
        .padding()

    }
}


struct NewPostView: View {
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var caption: String = ""
    @State private var posts: [Post] = []
    @State private var isUploading = false
    @Binding var isLoggedIn: Bool
    
    
    
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
                .background(Color.black) // Set the header background to black

                // Post a Photo Button
                Button(action: {
                    // Present image picker
                    showingImagePicker = true
                }) {
                    Text("Post a Photo")
                        .foregroundColor(.white)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
                .background(Color.black) // Set the button background to black

                // List of posts
                List(posts) { post in
                    PostView(post: post)
                        .listRowBackground(Color.black) // Set the list row background to black
                }
                .onAppear {
                    fetchPosts()
                }
                .background(Color.black) // Set the List's background to black
            }
            .background(Color.black.edgesIgnoringSafeArea(.all)) // Set the background color for the entire VStack to black
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
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
                    if let author = object["author"] as? PFUser, let file = object["image"] as? PFFileObject, let caption = object["caption"] as? String {
                        let postId = object.objectId ?? "unknown"
                        let authorName = author.username ?? "Anonymous"
                        
                        file.getDataInBackground { (data, error) in
                            if let data = data, let image = UIImage(data: data) {
                                let post = Post(id: postId, image: image, caption: caption, author: authorName)
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
    
    
    func uploadPost() {
        guard let selectedImage = selectedImage else {
            print("No image selected")
            return
        }
        
        if let imageData = selectedImage.jpegData(compressionQuality: 0.5) {
            isUploading = true // Start uploading
            let file = PFFileObject(name: "image.jpg", data: imageData)
            let post = PFObject(className: "Post")
            post["image"] = file
            post["caption"] = caption
            post["author"] = PFUser.current()
            
            post.saveInBackground { (success, error) in
                DispatchQueue.main.async {
                    self.isUploading = false // Stop uploading
                    if success {
                        print("Post uploaded successfully")
                        self.selectedImage = nil
                        self.caption = ""
                        self.fetchPosts() // Refresh the feed
                    } else if let error = error {
                        print("Error uploading post: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            print("Could not get JPEG representation of UIImage")
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
