//
//  Validation.swift
//  Authentication
//
//  Created by Madan AR on 20/10/21.
//

import Foundation

struct Validation {
    static let shared = Validation()
    
    func isValidEmail(email:String) -> Bool {
        
  //      guard email != nil else { return false }
        
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let pred = NSPredicate(format:"SELF MATCHES %@", regEx)
        return pred.evaluate(with: email)
    }
    
    func isValidPassword(password: String) -> Bool {
    //    guard password != nil else { return false }

        // at least one uppercase
        // at least one digit
        // at least one lowercase
        // 6 characters total
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{6,}")
        return passwordTest.evaluate(with: password)
    }
}
