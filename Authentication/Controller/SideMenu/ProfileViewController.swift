//
//  profViewController.swift
//  Authentication
//
//  Created by Madan AR on 31/10/21.
//

import UIKit
import Photos
import FirebaseStorage
import FirebaseStorageUI
import FirebaseAuth

class ProfileViewController: UIViewController, UINavigationControllerDelegate{
    // MARK: - Properties
    var imagePickerController = UIImagePickerController()
    let storage = Storage.storage().reference()
    let placeholderImage = UIImage(systemName: "person.fill")!
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainPurple
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(addImage))
        profileImageView.addGestureRecognizer(tap)
        profileImageView.isUserInteractionEnabled = true
        
        view.addSubview(profileImageView)
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.anchor(top: view.topAnchor, paddingTop: 88,
                                width: 120, height: 120)
        profileImageView.layer.cornerRadius = 120 / 2
        
        view.addSubview(removeImageButton)
        removeImageButton.anchor(top: view.topAnchor, right: view.rightAnchor,
                            paddingTop: 80, paddingRight: 32, width: 32, height: 32)
        
        view.addSubview(emailLabel)
        emailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailLabel.anchor(top: profileImageView.bottomAnchor, paddingTop: 12)
        
        view.addSubview(uidLabel)
        uidLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        uidLabel.anchor(top: emailLabel.bottomAnchor, paddingTop: 4)
        
        return view
    }()
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .white
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.borderWidth = 3
        iv.layer.borderColor = UIColor.white.cgColor
        return iv
    }()
    
    let removeImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "icons-edit").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(removeImage), for: .touchUpInside)
        return button
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = Auth.auth().currentUser?.email
        label.font = UIFont.boldSystemFont(ofSize: 26)
        label.textColor = .white
        return label
    }()
    
    let uidLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = Auth.auth().currentUser?.uid
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        return label
    }()
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(containerView)
        containerView.anchor(top: view.topAnchor, left: view.leftAnchor,
                             right: view.rightAnchor, height: 300)
        navigationController?.navigationBar.backgroundColor = nil
        imagePickerController.delegate = self
        profileImageView.image = placeholderImage
        getImage()
    }
 
    // MARK: - actions
    @objc func addImage(){
        self.imagePickerController.allowsEditing = true
        self.present(self.imagePickerController, animated:  true, completion:  nil)
    }
    
    @objc func removeImage(_ sender: Any) {
        profileImageView.image = placeholderImage
        NetworkManager.shared.deleteImage(fromURL: (UserDefaults.standard.value(forKey: "url") as? String ?? "invalid url"))
    }
    
    // MARK: - helper functions
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func getImage() {
          guard let urlString = UserDefaults.standard.value(forKey: "url") as? String else { return }
          NetworkManager.shared.downloadImage(fromURL: urlString) { image in
              guard let image = image else {
                  self.profileImageView.image = self.placeholderImage
                  return
              }
              DispatchQueue.main.async {
                  self.profileImageView.image = image
              }
          }
      }
}


extension ProfileViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        self.profileImageView.image = image
        guard let imageData = image.pngData() else { return }
        NetworkManager.shared.uploadImage(imageData: imageData)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true,completion: nil)
    }
    
}


extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    static let mainPurple = UIColor.rgb(red: 100, green: 0, blue: 100)
}



