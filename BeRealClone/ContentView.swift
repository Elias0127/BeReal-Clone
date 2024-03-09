//
//  ContentView.swift
//  BeRealClone
//
//  Created by Elias Woldie on 3/8/24.
//

import SwiftUI
import Parse

struct ContentView: View {
    @State private var isLoggedIn = PFUser.current() != nil
    @State private var isPresentingNewPostView = false
    
    var body: some View {
        NavigationView {
            if isLoggedIn {
                VStack {
                    Text("Welcome, \(PFUser.current()?.username ?? "User")!")
                    Button("Create New Post") {
                        isPresentingNewPostView = true
                    }
                    .padding()
                }
                .sheet(isPresented: $isPresentingNewPostView) {
                    NewPostView(isLoggedIn: $isLoggedIn)
                }
            } else {
                LoginView(isLoggedIn: $isLoggedIn)
            }
            onAppear {
                isLoggedIn = PFUser.current() != nil
            }
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
