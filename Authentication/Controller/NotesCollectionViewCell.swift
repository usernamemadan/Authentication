//
//  NotesCollectionViewCell.swift
//  Authentication
//
//  Created by Madan AR on 27/10/21.
//

import UIKit
import Foundation

class NotesCollectionViewCell: UICollectionViewCell {
    

    @IBOutlet weak var notesTitle: UILabel!
    @IBOutlet weak var notes: UILabel!
    
    func setup(with notes: Notes) {
        self.notesTitle.text = notes.dictionary["title"] as? String
        self.notes.text = notes.dictionary["notes"] as? String
    }
//    @IBAction func closeButtonTapped(_ sender: Any) {
//        print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&")
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let addNotesVC = storyboard.instantiateViewController(withIdentifier: "addNotes") as! AddNotesViewController
//        addNotesVC.delete()
//    }
}
