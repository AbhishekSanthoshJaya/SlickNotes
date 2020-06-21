//
//  DetailViewController.swift
//  SlickNotes
//
//  Created by user166476 on 6/19/20.
//  Copyright © 2020 Quasars. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var noteTitleLabel: UILabel!
    @IBOutlet weak var noteTextTextView: UITextView!
    @IBOutlet weak var noteDate: UILabel!

    @IBOutlet weak var noteLocationLabel: UILabel!
    
     func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let topicLabel = noteTitleLabel,
               let dateLabel = noteDate,
               let textView = noteTextTextView,
                let location = noteLocationLabel{
                topicLabel.text = detail.noteTitle
                dateLabel.text = SlickNotesDateHelper.convertDate(date: Date.init(seconds: detail.noteTimeStamp))
                textView.text = detail.noteText
                location.text = "\(detail.location)"
                
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
    }

   var detailItem: SlickNotes? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChangeNoteSegue" {
            let changeNoteViewController = segue.destination as! SlickNoteCreatorViewController
            if let detail = detailItem {
                changeNoteViewController.setChangingReallySimpleNote(
                    changingReallySimpleNote: detail)
            }
        }
    }

}

