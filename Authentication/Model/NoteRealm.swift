//
//  NoteRealm.swift
//  Authentication
//
//  Created by Madan AR on 31/10/21.
//

import Foundation
import RealmSwift
class NoteRealm: Object{
    @objc dynamic var userid = ""
    @objc dynamic var title = ""
    @objc dynamic var note = ""
    @objc dynamic var date = Date()
}
