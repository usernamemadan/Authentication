//
//  HomeViewController.swift
//  Authentication
//
//  Created by Madan AR on 19/10/21.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FirebaseFirestore
import FBSDKLoginKit
//import FacebookLogin



class HomeViewController: UIViewController {
    weak var delegate: HomeViewControllerDelegate?
    var notesArray: [Notes] = []
    var filteredNotes: [Notes] = []
    var hasMoreNotes = true
 //   var realmNotes : [NoteRealm] = []
    var listView = false
    var cellPerRow: CGFloat = 2
    var cellPerCol: CGFloat = 4
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        filteredNotes = notesArray
        presentLoginScreenIfUserNotLoggedIn()
        collectionView.dataSource = self
        collectionView.delegate = self
        let layout = UICollectionViewFlowLayout()
//        layout.itemSize = CGSize(width: 200, height: 400)
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
//        print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
       // getNotes()
        toggleView()
     
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.dash"), style: .done, target: self, action: #selector (didTapMenuButton))
        navigationController?.navigationBar.tintColor = .white
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hasMoreNotes = true
        getNotes()
        
    }
    
    func changeView(){
        if listView{
            let switchLayout = UIBarButtonItem(image: UIImage(systemName: "list.bullet.rectangle.fill"), style: .done, target: self, action: #selector(toggleView))
            let addNote = UIBarButtonItem(image: UIImage(systemName: "plus.square.fill"), style: .done, target: self, action: #selector(addButtonTapped))
            navigationItem.rightBarButtonItems = [addNote, switchLayout]
            cellPerRow = 2
            cellPerCol = 4
        }
        else{
            let switchLayout = UIBarButtonItem(image: UIImage(systemName: "square.grid.2x2.fill"), style: .done, target: self, action: #selector(toggleView))
            let addNote = UIBarButtonItem(image: UIImage(systemName: "plus.square.fill"), style: .done, target: self, action: #selector(addButtonTapped))
            navigationItem.rightBarButtonItems = [addNote, switchLayout]
            cellPerRow = 1
            cellPerCol = 8
        }
        listView = !listView
    }
    
    @objc func toggleView(){
        changeView()
        collectionView.reloadData()
    }
    
    @objc func addButtonTapped(){
        let addNotesVC = storyboard?.instantiateViewController(withIdentifier: "addNotes") as! AddNotesViewController
        navigationController?.pushViewController(addNotesVC, animated: true)
    }
    
    //        @IBAction func closeButtonTapped(_ sender: Any) {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                  let addNotesVC = storyboard.instantiateViewController(withIdentifier: "addNotes") as! AddNotesViewController
//                  addNotesVC.delete()
//    }
    
    
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
    
    func getNotes(){
        PersistentManager.shared.fetchNotes()
//        NetworkManager.shared.fetchNotes { notes in
//            self.notesArray = notes
//            self.filteredNotes = self.notesArray
//            DispatchQueue.main.async {
//                self.collectionView.reloadData()
//            }
//        }
//        NetworkManager.shared.paginate(paginate: false) { notes in
//            self.notesArray = notes
//         //   print("|||||||||||")
//            print(self.notesArray)
//            self.filteredNotes = self.notesArray
//            DispatchQueue.main.async {
//                self.collectionView.reloadData()
//            }
//        }
    
        NetworkManager.shared.fetchNotes { notes in
            if notes.count < 8{
                self.hasMoreNotes = false
            }
            self.notesArray = notes
            //   print("|||||||||||")
            print(self.notesArray)
            self.filteredNotes = self.notesArray
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    

    func logout(){
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
    
    func presentProfileScreen(){
//        let profileVC = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
//        navigationController?.pushViewController(profileVC, animated: true)
        let profileVC = profViewController()
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    
    @objc func didTapMenuButton(){
        delegate?.didTapMenuButton()
    }

}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredNotes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotesCollectionViewCell", for: indexPath) as! NotesCollectionViewCell
        cell.backgroundColor = .systemBlue
        cell.layer.cornerRadius = 15
        cell.setup(with: filteredNotes[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let addNotesVC = storyboard?.instantiateViewController(withIdentifier: "addNotes") as! AddNotesViewController
        addNotesVC.notesTitleText = filteredNotes[indexPath.row].dictionary["title"] as! String
        addNotesVC.notesText = filteredNotes[indexPath.row].dictionary["notes"] as! String
        addNotesVC.docID = filteredNotes[indexPath.row].dictionary["documentID"] as! String
        addNotesVC.updateFlag = true
        addNotesVC.realmIndex = indexPath.row
        
        navigationController?.pushViewController(addNotesVC, animated: true)
    }
    
 //   flow layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width)/cellPerRow - 10, height: collectionView.frame.size.height/cellPerCol)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    

}

extension HomeViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredNotes = []
        
        if searchText == "" {
            filteredNotes = notesArray
        }
        else{
            for notes in notesArray{
                if (notes.dictionary["title"] as! String).lowercased().contains(searchText.lowercased()){
                    filteredNotes.append(notes)
                }
            }
        }
        self.collectionView.reloadData()
    }
}
    
extension HomeViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > collectionView.contentSize.height-scrollView.frame.size.height-100{
            guard hasMoreNotes else { return}
            guard !fetchingMoreNotes else {
                print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
                return
                
            }
//            if fetchingMoreNotes && hasMoreNotes {
//                return
//            }
            print("scrolled")
            
            NetworkManager.shared.fetchMoreNotes { notes in
                if notes.count < 8{
                    self.hasMoreNotes = false
                }
                self.notesArray.append(contentsOf: notes)
                self.filteredNotes = self.notesArray
                self.collectionView.reloadData()
            }
//            NetworkManager.shared.paginate(paginate: true) { notes in
//                self.notesArray.append(contentsOf: notes)
//                self.filteredNotes = self.notesArray
//                self.collectionView.reloadData()
//            }
           
        }
    }
}
