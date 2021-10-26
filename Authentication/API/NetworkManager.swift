//
//  NetworkManager.swift
//  Authentication
//
//  Created by Madan AR on 20/10/21.
//

import Foundation
import FirebaseAuth

struct NetworkManager{
    static let shared = NetworkManager()
    
    func logUserIn(withEmail email: String, password: String, completion: AuthDataResultCallback?) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    func SignUserIn(withEmail email: String, password: String, completion: AuthDataResultCallback?) {
        Auth.auth().createUser(withEmail: email, password: password, completion: completion)
    }
}
