//
//  PostView.swift
//  BeRealClone
//
//  Created by Elias Woldie on 3/8/24.
//

import SwiftUI

struct PostView: View {
    var post: Post
    
    var body: some View {
        VStack(alignment: .leading) {
            Image(uiImage: post.image)
                .resizable()
                .scaledToFit()
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
