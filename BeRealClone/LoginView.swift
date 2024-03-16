//
//  LoginView.swift
//  BeRealClone
//
//  Created by Elias Woldie on 3/8/24.
//

import SwiftUI
import Parse


struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showingSignUp = false

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all) 

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
                
                Button("Login") {
                    login()
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.btn1)
                .cornerRadius(10)
                .padding(.horizontal)
                .frame(width: 330)
                
                Button("Signup") {
                    showingSignUp = true
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.btn1)
                .cornerRadius(10)
                .padding(.horizontal)
                .frame(width: 330)
                .sheet(isPresented: $showingSignUp) {
                    SignUpView()
                }
            }
        }
    }

    func login() {
        PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) in
            if let error = error {
                print("Error logging in: \(error.localizedDescription)")
            } else {
                print("Successfully logged in user: \(user?.username ?? "")")
                DispatchQueue.main.async {
                    self.isLoggedIn = true
                }
            }
        }
    }
}
