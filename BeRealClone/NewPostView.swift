//
//  NewPostView.swift
//  BeRealClone
//
//  Created by Elias Woldie on 3/8/24.
//

import Parse
import SwiftUI

struct Post: Identifiable {
    var id: String
    var image: UIImage?
    var caption: String
    var author: String
    var location: String?
    var timestamp: Date?
    var comments: [Comment] = []

}
struct Comment: Identifiable {
    var id: String
    var text: String
    var author: String
}


struct PostView: View {
    @Binding var post: Post
    @State private var newCommentText: String = ""
    @State private var isPostingComment: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            // Display post content
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
                Text(timestamp, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Display comments
            ForEach(post.comments) { comment in
                HStack {
                    Text(comment.author)
                        .fontWeight(.bold)
                    Text(comment.text)
                }
            }

            // Comment input field
            HStack {
                TextField("Add a comment...", text: $newCommentText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                if isPostingComment {
                    ProgressView()
                } else {
                    Button("Post") {
                        postComment()
                    }
                }
            }
        }
        .background(Color.black)
        .padding()
    }

    func postComment() {
        guard !newCommentText.isEmpty else { return }
        isPostingComment = true

        // Create a new Comment object
        let comment = PFObject(className: "Comment")
        comment["text"] = newCommentText
        comment["post"] = PFObject(withoutDataWithClassName: "Post", objectId: post.id)
        comment["author"] = PFUser.current()

        // Save the comment to Parse
        comment.saveInBackground { (success, error) in
            DispatchQueue.main.async {
                self.isPostingComment = false
                if success {
                    print("Comment posted successfully")
                    // Add the new comment to the post's comments array
                    let newComment = Comment(id: comment.objectId ?? "unknown", text: self.newCommentText, author: PFUser.current()?.username ?? "Anonymous")
                    self.post.comments.append(newComment)
                    self.newCommentText = "" // Clear the input field
                } else if let error = error {
                    print("Error posting comment: \(error.localizedDescription)")
                }
            }
        }
    }
}


struct NewPostView: View {
  @State private var posts: [Post] = []
  @State private var isUploading = false
  @Binding var isLoggedIn: Bool
  @State private var showingUploadPostView = false
  @State private var hasUploadedPost: Bool = false

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

      // Post a Photo Button
      Button(action: {
        showingUploadPostView = true  // Present the UploadPostView
      }) {
        Text("Post a Photo")
          .foregroundColor(.white)
          .frame(width: 200)
          .padding()
          .background(Color.blue)
          .cornerRadius(10)
      }
      .padding()

      // List of posts
        List($posts) { post in
        if hasUploadedPost {
          PostView(post: post)
            .listRowBackground(Color.black)
        } else {
          Text("Upload your first post to see others' posts!")
            .foregroundColor(.gray)
        }
      }
      .refreshable {
        fetchPosts()
      }
      .task {
        fetchPosts()
      }
      .listStyle(PlainListStyle())
    }
    .background(Color.black.edgesIgnoringSafeArea(.all))
    .sheet(isPresented: $showingUploadPostView) {
        UploadPostView(isPresented: $showingUploadPostView, didCompleteUpload: {
            self.fetchPosts() // Refresh the posts list
            self.hasUploadedPost = true // Update the state
        })
    }
    .onAppear {
        fetchUserData()
        fetchPosts()
    }
}

func fetchUserData() {
    // Fetch the current user's data, including the hasUploadedPost flag
    guard let currentUser = PFUser.current() else { return }
    hasUploadedPost = currentUser["hasUploadedPost"] as? Bool ?? false
}


func fetchPosts() {
    let query = PFQuery(className: "Post")
    query.includeKey("author")
    query.whereKey("createdAt", greaterThanOrEqualTo: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
    query.order(byDescending: "createdAt")
    query.limit = 10

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
                    let location = object["location"] as? String
                    let timestamp = object.createdAt

                    // Fetch comments for this post
                    let commentQuery = PFQuery(className: "Comment")
                    commentQuery.whereKey("post", equalTo: object)
                    commentQuery.includeKey("author")
                    commentQuery.findObjectsInBackground { (comments, error) in
                        var fetchedComments: [Comment] = []

                        if let comments = comments {
                            for comment in comments {
                                if let author = comment["author"] as? PFUser,
                                   let text = comment["text"] as? String {
                                    let commentId = comment.objectId ?? "unknown"
                                    let authorName = author.username ?? "Anonymous"

                                    let fetchedComment = Comment(id: commentId, text: text, author: authorName)
                                    fetchedComments.append(fetchedComment)
                                }
                            }
                        }

                        file.getDataInBackground { (data, error) in
                            if let data = data, let image = UIImage(data: data) {
                                let post = Post(id: postId, image: image, caption: caption, author: authorName, location: location, timestamp: timestamp, comments: fetchedComments)
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
}


  func fetchUserLastPostTimestamp(completion: @escaping (Date?) -> Void) {
    guard let currentUser = PFUser.current() else {
      completion(nil)
      return
    }

    let query = PFQuery(className: "Post")
    query.whereKey("author", equalTo: currentUser)
    query.order(byDescending: "createdAt")
    query.limit = 1

    query.findObjectsInBackground { (objects, error) in
      if let error = error {
        print("Error fetching user's last post: \(error.localizedDescription)")
        completion(nil)
      } else if let lastPost = objects?.first, let timestamp = lastPost.createdAt {
        completion(timestamp)
      } else {
        completion(nil)
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
