//
//  PersistantManager.swift
//  Authentication
//
//  Created by Madan AR on 29/10/21.
//

import Foundation
import RealmSwift
import FirebaseAuth

struct PersistentManager{
    static var shared = PersistentManager()
    var realmNotes : [NoteRealm] = []
    let realm = try! Realm()
   
    func add(data: NoteRealm){
        try! realm.write {
            realm.add(data)
            print(Realm.Configuration.defaultConfiguration.fileURL!)
        }
    }
    
    func delete(realmIndex: Int){
        try! realm.write {
            realm.delete(realmNotes[realmIndex])
        }
    }
    
    func update(data: NoteRealm, index: Int){
        try! realm.write {
            realm.delete(realmNotes[index])
            realm.add(data)
        }
    }
    
    mutating func fetchNotes(){
        var realmNotes : [NoteRealm] = []
        let notes = realm.objects(NoteRealm.self)
        for note in notes{
            realmNotes.append(note)
        }
        self.realmNotes = realmNotes
      //  completion(realmNotes)
    }
    
}
