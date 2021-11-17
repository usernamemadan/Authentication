//
//  NetworkManager.swift
//  Authentication
//
//  Created by Madan AR on 20/10/21.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

var fetchingMoreNotes = false
var lastDoc: QueryDocumentSnapshot?

enum QueryType{
    case initialFetch
    case paginationFetch

    static func getQuery(type: QueryType, archived: Bool) -> Query?  {
        guard let uid = Auth.auth().currentUser?.uid else { return nil}
        switch type{
        case .initialFetch:
            lastDoc = nil
            return Firestore.firestore().collection(uid).whereField("archived", isEqualTo: archived).order(by: "timeStamp").limit(to: 8)
            
        case .paginationFetch:
            guard let lastDoc = lastDoc else { return nil }
            return Firestore.firestore().collection(uid).whereField("archived", isEqualTo: archived).order(by: "timeStamp").start(afterDocument: lastDoc).limit(to: 8)
        }
    }
}


struct NetworkManager{
    static let shared = NetworkManager()
    let db = Firestore.firestore()
    let storage = Storage.storage()
    var uid: String {
        get {
            guard let uid = Auth.auth().currentUser?.uid else { return "user id not founnd" }
            return uid
        }
    }
 
    
    func logUserIn(withEmail email: String, password: String, completion: AuthDataResultCallback?) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    func SignUserIn(withEmail email: String, password: String, completion: AuthDataResultCallback?) {
        Auth.auth().createUser(withEmail: email, password: password, completion: completion)
    }
    
    func addNotestoFirebase(docID: String, note: Notes){
        db.collection(uid).document(docID).setData(note.dictionary)
    }
    
    func updateNotestoFirebase(docID: String, note: Notes){
        db.collection(uid).document(docID).updateData(note.dictionary)
    }
    
    func deleteNotesfromFirebase(docID: String){
        db.collection(uid).document(docID).delete()
    }
    
    
    func downloadImage(fromURL urlString: String, completion: @escaping(UIImage?) -> Void) {
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            let image = UIImage(data: data)
            completion(image)
        }
        task.resume()
    }
    
    func deleteImage(fromURL urlString: String){
        let storageRef = storage.reference(forURL: urlString)
        storageRef.delete { error in
            if let error = error {
                print(error)
            } else {
                print("deleted succesfully")
            }
        }
    }
    
    func uploadImage(imageData: Data){
        storage.reference().child(uid).putData(imageData, metadata: nil) { _, error in
            guard error == nil else { return }
            self.storage.reference().child(uid).downloadURL { url, error in
                guard let url = url, error == nil else { return }
                let urlString = url.absoluteString
                print("Download URL: \(urlString)")
                UserDefaults.standard.set(urlString, forKey: "url")
            }
        }
    }
    
    
    func fetchNotes(queryType: QueryType, archived: Bool, completion: @escaping(Result< [Notes], Error >) -> Void){
        guard let query = QueryType.getQuery(type: queryType, archived: archived) else { return }
        query.getDocuments { snapshot, error in
            var notes : [Notes] = []
            if error != nil {
                completion(.failure(error!))
                print(error!.localizedDescription)
                return
            }
            guard let snapshot = snapshot else { return }
            
            for document in snapshot.documents {
                let documentData = document.data()
                let docID = documentData["documentID"] as! String
                let noteTitle = documentData["title"] as! String
                let noteText = documentData["notes"] as! String
                let timeStamp = (documentData["timeStamp"] as! Timestamp).dateValue()
                let archived = documentData["archived"] as! Bool
                let note = Notes(documentID: docID, title: noteTitle, notes: noteText, timeStamp: timeStamp, archived: archived)
                notes.append(note)
            }
            
            lastDoc = snapshot.documents.last
            print(notes)
            completion(.success(notes))
        }
    }
}



