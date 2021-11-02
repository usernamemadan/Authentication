//
//  NetworkManager.swift
//  Authentication
//
//  Created by Madan AR on 20/10/21.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

var fetchingMoreNotes = false
var lastDoc: QueryDocumentSnapshot?

struct NetworkManager{
    static let shared = NetworkManager()
    let db = Firestore.firestore()
    
    
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
//        db.collection((uid)).getDocuments { <#QuerySnapshot?#>, <#Error?#> in
//            <#code#>
//        }
    }
    
    
//    func fetchNotes(completion: @escaping([Notes]) -> Void){
//        db.collection(uid).order(by: "timeStamp").getDocuments { snapshot, error in
//            var notes : [Notes] = []
//            if error == nil && snapshot != nil {
//                for document in snapshot!.documents {
//                    let documentData = document.data()
//                    let note = Notes(documentID: documentData["documentID"] as! String, title: documentData["title"] as! String, notes: documentData["notes"] as! String, timeStamp: (documentData["timeStamp"] as! Timestamp).dateValue())
//                    notes.append(note)
//
//                }
//
//                completion(notes)
//            }
//        }
//    }
    
    
    func fetchMoreNotes(completion: @escaping([Notes]) -> Void){
        print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
        fetchingMoreNotes = true
            guard let lastDocument = lastDoc else { return }
            db.collection(uid).order(by: "timeStamp").start(afterDocument: lastDocument).limit(to: 8).getDocuments { snapshot, error in
                var notes : [Notes] = []
                if error == nil && snapshot != nil {
                    for document in snapshot!.documents {
                        
                        let documentData = document.data()
                        let note = Notes(documentID: documentData["documentID"] as! String, title: documentData["title"] as! String, notes: documentData["notes"] as! String, timeStamp: (documentData["timeStamp"] as! Timestamp).dateValue())
                        notes.append(note)
                    }
                    lastDoc = snapshot!.documents.last
                    print("|||||||||||||||||||||||||||||||||||||")
                    print(notes)
//                    if paginate{
//                       fetchingMoreNotes = false
//                    }
                    fetchingMoreNotes = false
                    completion(notes)
                }
            }
          
        
        
        
    }
    
    func fetchNotes(completion: @escaping([Notes]) -> Void){
        db.collection(uid).order(by: "timeStamp").limit(to: 8).getDocuments { snapshot, error in
            var notes : [Notes] = []
            if error == nil && snapshot != nil {
                for document in snapshot!.documents {
                    let documentData = document.data()
                    let note = Notes(documentID: documentData["documentID"] as! String, title: documentData["title"] as! String, notes: documentData["notes"] as! String, timeStamp: (documentData["timeStamp"] as! Timestamp).dateValue())
                    notes.append(note)
                }
                lastDoc = snapshot!.documents.last
                
                print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%1111")
                print(notes)
                completion(notes)
            }
        }
    }
        
   
       
            
        
//        let first = db.collection(uid).order(by: "timeStamp").limit(to: 2).getDocuments(completion: FIRQuerySnapshotBlock
//
//        )
//        print(first)
//
//        first.addSnapshotListener { (snapshot, error) in
//            guard let snapshot = snapshot else {
//                print("Error retreving cities: \(error.debugDescription)")
//                return
//
//                for document in snapshot!.documents {
//                    let documentData = document.data()
//                    let note = Notes(documentID: documentData["documentID"] as! String, title: documentData["title"] as! String, notes: documentData["notes"] as! String, timeStamp: (documentData["timeStamp"] as! Timestamp).dateValue())
//                    notes.append(note)
//                }
//            }
//
           
            
//            guard let lastSnapshot = snapshot.documents.last else {
//                // The collection is empty.
//                return
//            }
//
//            // Construct a new query starting after this document,
//            // retrieving the next 25 cities.
//            let next = db.collection(uid).order(by: "timeStamp").start(afterDocument: lastSnapshot)
//
//            // Use the query for pagination.
//            // ...
//        }
//        print(notes)
//        completion(notes)
        
}

