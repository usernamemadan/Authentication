//
//  NotesViewController.swift
//  Authentication
//
//  Created by Madan AR on 26/10/21.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import UserNotifications


class AddNotesViewController: UIViewController {
    
    // MARK: - properties
    @IBOutlet weak var notes: UITextView!
    @IBOutlet weak var notesTitle: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var notesText: String = ""
    var notesTitleText: String = ""
    var docID: String = ""
    var realmIndex = 0
    var updateFlag = false
    var realmNotes : [NoteRealm] = []
    var setRemainder = false
    let notificationCenter = UNUserNotificationCenter.current()
    
    // MARK: - lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setText()
        configureBarButtons()
        navigationController?.navigationBar.tintColor = .white
    }
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
 
    }
    
    // MARK: - actions
    @IBAction func setRemainderTapped(_ sender: Any) {
        setRemainder = true
        
        UNUserNotificationCenter.current()
          .requestAuthorization(
            options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            print("Permission granted: \(granted)")
            guard granted else { return }
            self?.showNotification()
          }
    }
    
    @objc func deleteIconTapped(){
        NetworkManager.shared.deleteNotesfromFirebase(docID: docID)
  //      PersistentManager.shared.delete(realmIndex: realmIndex)

        navigationController?.popViewController(animated: true)
    }
    
    @objc func saveButtonTapped(){
        let uid = NetworkManager.shared.uid
        
//        let realmData = NoteRealm()
//        realmData.userid = uid
//        realmData.title = notesTitle.text!
//        realmData.note = notes.text!
//        realmData.date = Date()
        
        if  notesTitle.text! != "" && notes.text! != "" {
            
            if updateFlag {
                let note = Notes(documentID: docID, title: notesTitle.text!, notes: notes.text!, timeStamp: Date(), archived: false)
                NetworkManager.shared.updateNotestoFirebase(docID: docID, note: note)
             //   PersistentManager.shared.update(data: realmData, index: realmIndex)
            }
            else{
                let document = NetworkManager.shared.db.collection(uid).document()
                docID = document.documentID
                let note = Notes(documentID: document.documentID, title: notesTitle.text!, notes: notes.text!, timeStamp: Date(), archived: false)
                NetworkManager.shared.addNotestoFirebase(docID: document.documentID, note: note)
     //           PersistentManager.shared.add(data: realmData)
            }
        }
        if setRemainder{
            UserDefaults.standard.set(datePicker.date, forKey: docID)
        }
        navigationController?.popViewController(animated: true)
    }
    
    @objc func archiveButtonTapped() {
        var archived = false
        if showArchivedNotes{
            archived = true
        }
        let note = Notes(documentID: docID, title: notesTitle.text!, notes: notes.text!, timeStamp: Date(), archived: !archived)
        NetworkManager.shared.updateNotestoFirebase(docID: docID, note: note)
    //  PersistentManager.shared.update(data: realmData, index: realmIndex)
        navigationController?.popViewController(animated: true)
        
    }
    
    // MARK: - helper functions
    func setText(){
        self.notesTitle.text = notesTitleText
        self.notes.text = notesText
    }
    
    func configureBarButtons(){
        let trash = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteIconTapped))
        let save = UIBarButtonItem(barButtonSystemItem: .save , target: self, action: #selector(saveButtonTapped))
        let archive = UIBarButtonItem(barButtonSystemItem: .action , target: self, action: #selector(archiveButtonTapped))
        if !updateFlag {
            archive.isEnabled = false
            archive.tintColor = UIColor.clear
        }
        navigationItem.rightBarButtonItems = [save, trash, archive]
    }
    
    func showSuccessAlert() {
        let dialogMessage = UIAlertController(title: "Notification Scheduled", message: "At " + formattedDate(date: datePicker.date) , preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            self.saveButtonTapped()
         })
        dialogMessage.addAction(ok)
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    func formattedDate(date: Date) -> String
        {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM y HH:mm"
            return formatter.string(from: date)
        }
    
    func showNotification() {
        notificationCenter.getNotificationSettings { (settings) in
            DispatchQueue.main.async
            {
                let title = self.notesTitle.text!
                let message = self.notes.text!
                let date = self.datePicker.date
                
                guard title != "" && message != "" else { return }
                
                if(settings.authorizationStatus == .authorized)
                {
                    let content = UNMutableNotificationContent()
                    content.title = title
                    content.body = message
                    content.sound = UNNotificationSound.default
                    
                    let dateComp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    
                    self.notificationCenter.add(request) { (error) in
                        if(error != nil)
                        {
                            print("Error " + error.debugDescription)
                            return
                        }
                    }
                    self.showSuccessAlert()
                }
            }
        }
    }
}
