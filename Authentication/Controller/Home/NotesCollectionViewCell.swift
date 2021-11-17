//
//  NotesCollectionViewCell.swift
//  Authentication
//
//  Created by Madan AR on 27/10/21.
//

import UIKit
import Foundation

class NotesCollectionViewCell: UICollectionViewCell {
    
    // MARK: - properties
    @IBOutlet weak var notesTitle: UILabel!
    @IBOutlet weak var notes: UILabel!
    @IBOutlet weak var timer: UIButton!
    
    // MARK: - helper functions
    func setup(with notes: Notes) {
        self.notesTitle.text = notes.dictionary["title"] as? String
        self.notes.text = notes.dictionary["notes"] as? String
        let docID = notes.dictionary["documentID"] as? String
        timer.isHidden = false
        guard let date = UserDefaults.standard.object(forKey: docID!) as? Date else {
            timer.isHidden = true
            return
        }
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        let time = df.string(from: date)
        timer.setTitle(time, for: .normal)
    }
}
