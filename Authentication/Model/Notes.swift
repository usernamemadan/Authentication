//
//  Notes.swift
//  Authentication
//
//  Created by Madan AR on 27/10/21.
//

import Foundation

struct Notes{
    var documentID: String
    var title: String
    var notes: String
    var timeStamp: Date
    var archived: Bool
    
    
    init(documentID: String, title: String, notes: String, timeStamp: Date, archived: Bool){
        self.title = title
        self.notes = notes
        self.timeStamp = timeStamp
        self.documentID = documentID
        self.archived = archived
    }
    
    var dictionary: [String: Any] {
        return[
            "title": title,
            "notes": notes,
            "timeStamp": timeStamp,
            "documentID": documentID,
            "archived": archived
        ]
    }
}

//var notesArray[Notes] =[ Notes(title: "test", notes: "test", timeStamp: Date())]



//extension Notes: DocumentSerializable {
//    init?(dictionary: [String : Any]) {
//
//        guard let title = dictionary["title"] as? String,
//              let notes = dictionary["notes"] as? String,
//              let timeStamp = dictionary["timeStamp"] as? Date else { return }
//
//        self!.init(title: title, notes: notes, timeStamp: timeStamp)
//    }
 


