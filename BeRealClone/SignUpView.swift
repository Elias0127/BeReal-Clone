//
//  SignUpView.swift
//  BeRealClone
//
//  Created by Elias Woldie on 3/8/24.
//

import SwiftUI
import Parse


struct SignUpView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("Sign Up") {
                self.signUp()
            }
            .padding()
        }
    }
    
    func signUp() {
        print("Sign Up button pressed") // This should appear in the console when the button is pressed
        let newUser = PFUser()
        newUser.username = username
        newUser.password = password
        
        newUser.signUpInBackground { (success, error) in
            DispatchQueue.main.async {
                if success {
                    print("User registered successfully")
                    // Proceed to the main part of the app
                } else {
                    print("Error: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }

}
