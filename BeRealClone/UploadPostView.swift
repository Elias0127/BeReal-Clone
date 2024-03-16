//
//  UploadPostView.swift
//  BeRealClone
//
//  Created by Elias Woldie on 3/8/24.
//

import Foundation
import SwiftUI
import Parse


struct UploadPostView: View {
    @Binding var isPresented: Bool
    var didCompleteUpload: () -> Void
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var caption: String = ""
    @State private var isUploading = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showActionSheet = false

    var body: some View {
        NavigationView {
            VStack {
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                } else {
                    Button("Select Photo") {
                        showActionSheet = true
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .actionSheet(isPresented: $showActionSheet) {
                        ActionSheet(
                            title: Text("Select Photo"),
                            message: nil,
                            buttons: [
                                .default(Text("Take Photo")) {
                                    sourceType = .camera
                                    showingImagePicker = true
                                },
                                .default(Text("Choose Photo")) {
                                    sourceType = .photoLibrary
                                    showingImagePicker = true
                                },
                                .cancel()
                            ]
                        )
                    }
                }

                TextField("Caption", text: $caption)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                if isUploading {
                    ProgressView("Uploading...")
                }

                Spacer()
            }
            .padding()
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Spacer()
                        Text("Post Photo")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                        Spacer()
                    }
                }
            }

        
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Post") {
                    uploadPost()
                }.disabled(selectedImage == nil || isUploading)
            )
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage, sourceType: sourceType)
            }
        }
    }
    
    
    func uploadPost() {
        // Ensure an image is selected
        guard let selectedImage = selectedImage else {
            print("No image selected")
            return
        }
        
        // Begin uploading
        isUploading = true
        
        // Convert image to data
        if let imageData = selectedImage.jpegData(compressionQuality: 0.5) {
            // Create Parse file object
            let file = PFFileObject(name: "image.jpg", data: imageData)
            
            // Create Post object
            let post = PFObject(className: "Post")
            post["image"] = file
            post["caption"] = caption
            post["author"] = PFUser.current()
            
            // Save post object in background
            post.saveInBackground { (success, error) in
                DispatchQueue.main.async {
                    self.isUploading = false
                    if success {
                        print("Post uploaded successfully")
                        // Update hasUploadedPost for the current user
                        if let currentUser = PFUser.current() {
                            currentUser["hasUploadedPost"] = true
                            currentUser.saveInBackground { (success, error) in
                                if success {
                                    print("User hasUploadedPost updated successfully")
                                } else if let error = error {
                                    print("Error updating user hasUploadedPost: \(error.localizedDescription)")
                                }
                            }
                        }
                        self.isPresented = false
                        self.didCompleteUpload()
                    } else if let error = error {
                        print("Error uploading post: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            isUploading = false
            print("Could not get JPEG representation of UIImage")
        }
    }
}

