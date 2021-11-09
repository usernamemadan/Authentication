//
//  SignUpViewController.swift
//  Authentication
//
//  Created by Madan AR on 18/10/21.
//

import UIKit
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController {
    // MARK: - properties
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - actions
    @IBAction func signUp(_ sender: Any) {
        register()
    }
    
    @IBAction func alreadyHaveTheAccountClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - helper functions
    func register() {
        guard let email = email.text else { return }
        guard let password = password.text else { return }
        guard Validation.shared.isValidEmail(email: email) && Validation.shared.isValidPassword(password: password) else {
            showErrorAlert(error: "please enter valid username and password")
            return
        }
        NetworkManager.shared.SignUserIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            if error != nil{
                print(error!)
                self.showErrorAlert(error: error!.localizedDescription)
            }
            else{
                self.showSuccessAlert()
            }
        }
    }
    
    func showErrorAlert(error: String) {
        let dialogMessage = UIAlertController(title: "error", message: error, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: .none)
        dialogMessage.addAction(ok)
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    func showSuccessAlert() {
        let dialogMessage = UIAlertController(title: "Done", message: "account created successfully", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            self.dismiss(animated: true, completion: nil)
         })
        dialogMessage.addAction(ok)
        self.present(dialogMessage, animated: true, completion: nil)
    }

}
