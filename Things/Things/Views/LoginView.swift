//
//  LoginView.swift
//  Things
//
//  Created by MatKomp on 05/11/2024.
//
import SwiftUI

struct LoginView: View{
    @State private var email: String = ""
    @State private var password: String = ""
    
    
    var body: some View{
        LogoImageView()
        
        Text("Log in to your account")
        Text("Email")
        TextField("", text: $email)
        Text("Password")
        TextField("", text: $password)
        Button("Log in"){
            
        }
        Text("Don't have an account? Create")
    }
    
    
    
    
    
}
