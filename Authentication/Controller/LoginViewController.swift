//
//  ViewController.swift
//  Authentication
//
//  Created by Madan AR on 18/10/21.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
//import FacebookCore
//import FacebookLogin
//import FBSDKCoreKit
import FBSDKLoginKit


class LoginViewController: UIViewController {
 
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    let signInConfig = GIDConfiguration.init(clientID: "171806751686-5s7j4dquffnd9vgflifhvj4nnn41lvpl.apps.googleusercontent.com")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func login(_ sender: Any) {
        //return if username and password in not valid
        guard let email = email.text else { return }
        guard let password = password.text else { return }
        guard Validation.shared.isValidEmail(email: email) && Validation.shared.isValidPassword(password: password) else {
            showErrorAlert(error: "invalid username or password")
            return
        }
        //login with email and password
        NetworkManager.shared.logUserIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                print(error.localizedDescription)
                self.showErrorAlert(error: error.localizedDescription)
                return
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func createAccount(_ sender: Any) {
       presentSignUpScreen()
    }
        
    
    func showErrorAlert(error: String) {
        let dialogMessage = UIAlertController(title: "error", message: error, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: .none)
        dialogMessage.addAction(ok)
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    func presentSignUpScreen() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "signUp") as! SignUpViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @IBAction func loginWithGoogle(_ sender: Any){
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { [weak self] user, error in
            guard let self = self else { return }
            if let error = error {
                self.showErrorAlert(error: error.localizedDescription)
                return
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func loginWithFacebook(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile"], from: self) { result, error in
            if let error = error {
                print("Encountered Erorr: \(error)")
            }
            else if let result = result, result.isCancelled {
                print("Cancelled")
            }
            else {
                print("Logged In")
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}

