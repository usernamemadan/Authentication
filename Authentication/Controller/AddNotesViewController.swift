//
//  NotesViewController.swift
//  Authentication
//
//  Created by Madan AR on 26/10/21.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth


class AddNotesViewController: UIViewController {
    @IBOutlet weak var notes: UITextView!
    @IBOutlet weak var notesTitle: UITextField!
    var notesText: String = ""
    var notesTitleText: String = ""
    var docID: String = ""
    var realmIndex = 0
    var updateFlag = false
    var realmNotes : [NoteRealm] = []
    
    
 //   let db = Firestore.firestore()
    
    
    func enableSaveButton(){
        let trash = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteIconTapped))
        let save = UIBarButtonItem(barButtonSystemItem: .save , target: self, action: #selector(saveButtonTapped))
        navigationItem.rightBarButtonItems = [save, trash]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setText()
        enableSaveButton()
        navigationController?.navigationBar.tintColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @objc func deleteIconTapped(){
        delete()
    }
    
    func delete(){
        NetworkManager.shared.deleteNotesfromFirebase(docID: docID)
        PersistentManager.shared.delete(realmIndex: realmIndex)

        navigationController?.popViewController(animated: true)
    }

    @objc func saveButtonTapped(){
        let uid = NetworkManager.shared.uid
        
        let realmData = NoteRealm()
        realmData.userid = uid
        realmData.title = notesTitle.text!
        realmData.note = notes.text!
        realmData.date = Date()
        
        if  notesTitle.text! != "" && notes.text! != "" {
            
            if updateFlag {
                let note = Notes(documentID: docID, title: notesTitle.text!, notes: notes.text!, timeStamp: Date())
                NetworkManager.shared.updateNotestoFirebase(docID: docID, note: note)
                PersistentManager.shared.update(data: realmData, index: realmIndex)
            }
            else{
                let document = NetworkManager.shared.db.collection(uid).document()
                let note = Notes(documentID: document.documentID, title: notesTitle.text!, notes: notes.text!, timeStamp: Date())
                NetworkManager.shared.addNotestoFirebase(docID: document.documentID, note: note)
                PersistentManager.shared.add(data: realmData)
            }
        }
        navigationController?.popViewController(animated: true)
    }

    func setText(){
        self.notesTitle.text = notesTitleText
        self.notes.text = notesText
    }


}
