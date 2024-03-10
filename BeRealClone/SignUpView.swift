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
        ZStack {
            VStack {
                Text("BeReal.")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()
                
                TextField("Username", text: $username)
                    .foregroundColor(.white)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.txtC.opacity(3.5))
                            .frame(maxWidth: .infinity, minHeight: 44)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .frame(width: 330)
                
                SecureField("Password", text: $password)
                    .foregroundColor(.white)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.txtC.opacity(3.5))
                            .frame(maxWidth: .infinity, minHeight: 44)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .frame(width: 330)
                
                Button("Sign Up") {
                    self.signUp()
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.btn1)
                .cornerRadius(10)
                .padding(.horizontal)
                .frame(width: 330)
            }
        }
    }
    
    func signUp() {
        let newUser = PFUser()
        newUser.username = username
        newUser.password = password
        
        newUser.signUpInBackground { (success, error) in
            DispatchQueue.main.async {
                if success {
                    print("User registered successfully")
                } else {
                    print("Error: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
}
