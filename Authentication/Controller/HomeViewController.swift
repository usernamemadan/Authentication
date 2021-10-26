//
//  HomeViewController.swift
//  Authentication
//
//  Created by Madan AR on 19/10/21.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

import FBSDKLoginKit
//import FacebookLogin

protocol HomeViewControllerDelegate: AnyObject{
    func didTapMenuButton()
}

class HomeViewController: UIViewController {
    weak var delegate: HomeViewControllerDelegate?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        presentLoginScreenIfUserNotLoggedIn()
        
       // implementSideMenu()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.dash"), style: .done, target: self, action: #selector (didTapMenuButton))
        
    }
    


    
    func presentLoginScreenIfUserNotLoggedIn() {
        // return if logged in using email
        if Auth.auth().currentUser?.uid != nil {
            return
        }
        // return if logged with facebook
        if let token = AccessToken.current, !token.isExpired {
            return
        }
        // if not logged in with google then present login screen
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if user == nil {
                DispatchQueue.main.async {
                    self.presentLoginScreen()
                }
            }
          }
    }
 
    
    func presentLoginScreen() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "login") as! LoginViewController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
 
    func showErrorAlert(error: String) {
        let dialogMessage = UIAlertController(title: "error", message: error, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: .none)
        dialogMessage.addAction(ok)
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    func showSuccessAlert() {
        let dialogMessage = UIAlertController(title: "Done", message: "successfully logged out ", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            self.presentLoginScreen()
         })
        dialogMessage.addAction(ok)
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    @IBAction func logout(_ sender: Any) {
        do {
            let loginManager = LoginManager()
            loginManager.logOut()
            GIDSignIn.sharedInstance.signOut()
            try Auth.auth().signOut()
            showSuccessAlert()
        }
        catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            showErrorAlert(error: signOutError.localizedDescription)
        }
    }
    
    @objc func didTapMenuButton(){
        delegate?.didTapMenuButton()
    }

}


//    var sideBarView: UIView!
//    var tableView: UITableView!
//    var isSidebarEnabled: Bool = false
    
//    func implementSideMenu() {
//        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.dash"), style: .done, target: self, action: #selector (didTapMenuButton))
//
//        sideBarView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: self.view.bounds.height))
//        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: self.view.bounds.height))
//        tableView.backgroundColor = .gray
//        self.view.addSubview(sideBarView)
//        self.sideBarView.addSubview(tableView)
//    }
//
    

//    @objc func didTapMenuButton() {
//
//        if isSidebarEnabled {
//            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
//                self.sideBarView.frame = CGRect(x: 0, y: 0, width: 0, height: self.view.bounds.height)
//                self.tableView.frame = CGRect(x: 0, y: 0, width: 0, height: self.view.bounds.height)
//            }, completion: nil)
//            isSidebarEnabled = false
//        }
//        else{
//            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
//                self.sideBarView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width / 1.3, height: self.view.bounds.height)
//                self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width / 1.3, height: self.view.bounds.height)
//            }, completion: nil)
//            isSidebarEnabled = true
//        }
//
//    }
