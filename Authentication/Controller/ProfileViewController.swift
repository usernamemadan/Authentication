//
//  ProfileViewController.swift
//  Authentication
//
//  Created by Madan AR on 28/10/21.
//

import UIKit
import Photos
import FirebaseStorage
import FirebaseStorageUI
import FirebaseAuth

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var image: UIImageView!
    var imagePickerController = UIImagePickerController()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getProfileImage()
        checkPermissions()
        imagePickerController.delegate = self
    }
    
    @IBAction func addImageTapped(_ sender: Any) {
        self.imagePickerController.sourceType = .photoLibrary
        self.present(self.imagePickerController, animated:  true, completion:  nil)
    }
     
    func checkPermissions() {
       if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
                                PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
                                    ()
                                })
                            }

                            if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
                            } else {
                                PHPhotoLibrary.requestAuthorization(requestAuthroizationHandler)
                            }
    }
    
    func requestAuthroizationHandler(status: PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            print("We have access to photos")
        } else {
            print("We dont have access to photos")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            print(url)
            uploadToCloud(fileURL: url)
        }
        
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    func uploadToCloud(fileURL : URL) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let storage = Storage.storage()
        let data = Data()
        let storageRef = storage.reference()
        let localFile = fileURL
        let photoRef = storageRef.child(uid)
        let uploadTask = photoRef.putFile(from: localFile, metadata: nil) { (metadata, err) in
            guard let metadata = metadata else {
                print(err?.localizedDescription)
                return
            }
            print("Photo Upload")
            self.getProfileImage()
            
        }
    }
    
    func getProfileImage() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let ref = storageRef.child(uid)
//        image.sd_setImage(with: ref)
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        ref.getData(maxSize: 5 * 1024 * 1024) { data, error in
          if let error = error {
            // Uh-oh, an error occurred!
          } else {
            // Data for "images/island.jpg" is returned
            let image = UIImage(data: data!)
              DispatchQueue.main.async {
                  self.image.image = image
              }
              
          }
        }
    }
}
