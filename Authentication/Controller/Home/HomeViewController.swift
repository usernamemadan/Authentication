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

var showArchivedNotes = false

class HomeViewController: UIViewController {
    
// MARK: - properties
    weak var delegate: HomeViewControllerDelegate?
    var notesArray: [Notes] = []
    var filteredNotes: [Notes] = []
    var hasMoreNotes = true
    var listView = false
    var cellPerRow: CGFloat = 2
    var cellPerCol: CGFloat = 4
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presentLoginScreenIfUserNotLoggedIn()
        
        searchBar.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        collectionView.backgroundColor = .systemIndigo
       
        configureLeftBarButton()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        listView = false
        toggleView()
        hasMoreNotes = true
        notesArray = []
        filteredNotes = notesArray
        if showArchivedNotes{
            getArhivedNotes()
        }
        else {
            getNotes()
        }
        
    }
    
    //MARK: - actions
    
    @objc func didTapMenuButton(){
        delegate?.didTapMenuButton()
    }
    
    @objc func toggleView(){
        changeView()
        collectionView.reloadData()
    }
    
    @objc func addButtonTapped(){
        let addNotesVC = storyboard?.instantiateViewController(withIdentifier: "addNotes") as! AddNotesViewController
        navigationController?.pushViewController(addNotesVC, animated: true)
    }
    
    // MARK: - helper functions
    
    func changeView(){
        if listView{
            let switchLayout = UIBarButtonItem(image: UIImage(systemName: "list.bullet.rectangle.fill"), style: .done, target: self, action: #selector(toggleView))
            let addNote = UIBarButtonItem(image: UIImage(systemName: "plus.square.fill"), style: .done, target: self, action: #selector(addButtonTapped))
            if showArchivedNotes{
                addNote.isEnabled = false
                addNote.tintColor = UIColor.clear
            }
            navigationItem.rightBarButtonItems = [addNote, switchLayout]
            cellPerRow = 2
            cellPerCol = 4
        }
        else{
            let switchLayout = UIBarButtonItem(image: UIImage(systemName: "square.grid.2x2.fill"), style: .done, target: self, action: #selector(toggleView))
            let addNote = UIBarButtonItem(image: UIImage(systemName: "plus.square.fill"), style: .done, target: self, action: #selector(addButtonTapped))
            if showArchivedNotes{
                addNote.isEnabled = false
                addNote.tintColor = UIColor.clear
            }
            navigationItem.rightBarButtonItems = [addNote, switchLayout]
            cellPerRow = 1
            cellPerCol = 8
        }
        listView = !listView
    }
    
    func configureLeftBarButton(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.dash"), style: .done, target: self, action: #selector (didTapMenuButton))
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.backgroundColor = .systemIndigo
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
    
    func getNotes() {
        PersistentManager.shared.fetchNotes()

        NetworkManager.shared.fetchNotes(queryType: .initialFetch, archived: false) { result in
            switch result {
            case .failure(let error):
                print("error while fetching notes")
            case .success(let notes):
                self.updatePageUI(notes: notes)
            }
        }
    }
    
    func getArhivedNotes() {
        NetworkManager.shared.fetchNotes(queryType: .initialFetch, archived: true) { result in
            switch result {
            case .failure(let error):
                print("error while fetching notes")
            case .success(let notes):
                self.updatePageUI(notes: notes)
            }
        }
        
    }
    
    func updatePageUI(notes: [Notes]){
        if notes.count < 8 {
            self.hasMoreNotes = false
        }
        self.notesArray.append(contentsOf: notes)
        self.filteredNotes = self.notesArray
        DispatchQueue.main.async {
            self.collectionView.reloadData()
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
        let profileVC = ProfileViewController()
        navigationController?.pushViewController(profileVC, animated: true)
    }
}

// MARK:  UICollectionViewDelegateFlowLayout
extension HomeViewController:  UICollectionViewDelegateFlowLayout{
   
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

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredNotes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotesCollectionViewCell", for: indexPath) as! NotesCollectionViewCell
        cell.backgroundColor = .rgb(red: 176, green: 224, blue: 230)
        cell.layer.cornerRadius = 15
        cell.setup(with: filteredNotes[indexPath.row])
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let addNotesVC = storyboard?.instantiateViewController(withIdentifier: "addNotes") as! AddNotesViewController
        addNotesVC.notesTitleText = filteredNotes[indexPath.row].dictionary["title"] as! String
        addNotesVC.notesText = filteredNotes[indexPath.row].dictionary["notes"] as! String
        addNotesVC.docID = filteredNotes[indexPath.row].dictionary["documentID"] as! String
        addNotesVC.updateFlag = true
        addNotesVC.realmIndex = indexPath.row
        
        navigationController?.pushViewController(addNotesVC, animated: true)
    }
}

// MARK: - UISerchBarDelegate
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
    
// MARK: - UIScrllViewDelegate
extension HomeViewController: UIScrollViewDelegate{
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height{
            guard hasMoreNotes else { return }
            guard !fetchingMoreNotes else {
              //  print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
                return
            }
            
            if showArchivedNotes {
                NetworkManager.shared.fetchNotes(queryType: .paginationFetch, archived: true) { result in
                    switch result{
                    case .failure(let error):
                        print(error.localizedDescription)
                    case .success(let notes):
                        self.updatePageUI(notes: notes)
                    }
                }
            }
            else{
                NetworkManager.shared.fetchNotes(queryType: .paginationFetch, archived: false) { result in
                    switch result{
                    case .failure(let error):
                        print(error.localizedDescription)
                    case .success(let notes):
                        self.updatePageUI(notes: notes)
                    }
                }
            }
            
  
          
        }
    }
}

//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let position = scrollView.contentOffset.y
//        if position > collectionView.contentSize.height-scrollView.frame.size.height-100{
//            guard hasMoreNotes else { return}
//            guard !fetchingMoreNotes else {
//                print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
//                return
//            }
//
//            NetworkManager.shared.fetchMoreNotes { result in
//
//                switch result{
//
//                case .failure(let error):
//                    print(error.localizedDescription)
//
//                case .success(let notes):
//                    if notes.count < 8{
//                        self.hasMoreNotes = false
//                    }
//                    self.notesArray.append(contentsOf: notes)
//                    self.filteredNotes = self.notesArray
//                    DispatchQueue.main.async {
//                        self.collectionView.reloadData()
//                    }
//                }
//
//            }
//        }
//    }
