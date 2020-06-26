//
//  DetailViewController.swift
//  SlickNotes
//
//  Created by user166476 on 6/19/20.
//  Copyright © 2020 Quasars. All rights reserved.
//

import UIKit

class NoteDetailViewController: UIViewController {

    @IBOutlet weak var noteTitleLabel: UILabel!
    @IBOutlet weak var noteTextTextView: UITextView!
    @IBOutlet weak var noteDate: UILabel!

    @IBOutlet weak var noteLocationLabel: UILabel!
    
    var latitude: String!
    var longitude: String!
    var folderSelectedName: String?
    
    @IBOutlet weak var noteLocationOutImg: UIImageView!
    
    
    
    
    // All views
    
    var textViewTitle: UITextView!
    var noteDateLabel: UITextField!
    
    
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
                latitude = detail.latitude
                longitude = detail.longitude
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        noteLocationOutImg.isUserInteractionEnabled = true
        noteLocationOutImg.addGestureRecognizer(tapGestureRecognizer)
    }

    
    
   var detailItem: SlickNotes? {
        didSet {
            // Update the view.
//            configureView()
            setUpView()
            
        }
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        
        let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let mapViewController = storyBoard.instantiateViewController(withIdentifier: "mapView") as! MapViewController
        
        mapViewController.latitude = latitude
        mapViewController.longitude = longitude

        self.navigationController?.pushViewController(mapViewController, animated: true)
        // Your action
    }
    
    @IBAction func editButtonDown(_ sender: Any) {
        
        let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let SlickNoteCreatorViewController = storyBoard.instantiateViewController(withIdentifier: "SlickNoteCreatorViewController") as! SlickNoteCreatorViewController
        SlickNoteCreatorViewController.changingReallySimpleNote = detailItem
        SlickNoteCreatorViewController.folderSelectedName = folderSelectedName
        self.navigationController?.pushViewController(SlickNoteCreatorViewController, animated: true)

    }
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showChangeNoteSegue" {
//            let changeNoteViewController = (segue.destination as! UINavigationController).topViewController as! SlickNoteCreatorViewController
//            if let detail = detailItem {
//                changeNoteViewController.setChangingReallySimpleNote(
//                    changingReallySimpleNote: detail)
//            }
//        }
//    }
  //  (segue.destination as! UINavigationController).topViewController as! DetailViewController

    
    
    func setUpView(){
           
           
           // Add title
           
           textViewTitle = UITextView()
           textViewTitle.text = "Enter Title"
           textViewTitle.textColor = UIColor.lightGray
           textViewTitle.textAlignment = .center
          
          
          textViewTitle.heightAnchor.constraint(equalToConstant: 20).isActive = true
          textViewTitle.delegate = self
          textViewTitle.isScrollEnabled = false
           textViewTitle.font = UIFont.preferredFont(forTextStyle: .largeTitle)
          textViewDidChange(textViewTitle)
           
           // Add date
           noteDateLabel =  UITextField()
           noteDateLabel.font = UIFont.preferredFont(forTextStyle: .headline)
           noteDateLabel.textAlignment = .center
           
           
           
           // Add a horizontal line
           let hr = UIView()
           hr.backgroundColor = .black
           hr.translatesAutoresizingMaskIntoConstraints = false
           hr.heightAnchor.constraint(equalToConstant: 50)
           hr.widthAnchor.constraint(equalToConstant: 50)
           
           
           
           // Add category
           
//           let categoryLabel = UILabel()
//           categoryLabel.text = "Category: "
//           categoryLabel.font = UIFont.preferredFont(forTextStyle: .headline)
//           categoryLabel.textAlignment = .right
//
//           categoryTextField = UITextField()
//           categoryTextField.inputView = categoryPicker
//           categoryTextField.text = folderSelectedName
//           categoryTextField.textAlignment = .left
//           categoryTextField.font = UIFont.preferredFont(forTextStyle: .headline)
//
            
            let locationLabel = UITextField()
            locationLabel.text = 
           
           let hStack = UIStackView(arrangedSubviews: [ categoryLabel,categoryTextField])
           hStack.distribution = .fillEqually
           hStack.alignment = .center

           
           
           // add first Text view
           let textView1 = UITextView()
           textView1.text = "Enter Description"
           textView1.textColor = UIColor.lightGray
           textView1.textAlignment = .center
           
           
           textView1.heightAnchor.constraint(equalToConstant: 80).isActive = true
           textView1.delegate = self
           textView1.isScrollEnabled = false
           textView1.font = UIFont.preferredFont(forTextStyle: .headline)
           textViewDidChange(textView1)
           
           
           
           
           
           
           // add scroll view and vertical stack
           let scrollView = UIScrollView()
           scrollView.translatesAutoresizingMaskIntoConstraints = false
           //        textView1.translatesAutoresizingMaskIntoConstraints = false
           
           
           view.addSubview(scrollView)
           NSLayoutConstraint.activate([
               scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor
               ),
               
               
               scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor
               ),
               
               scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor
               ),
               
               scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor
               )
           ])
           
           
           viewsList = [textViewTitle,noteDateLabel,hStack,hr,textView1]
           vstackView = UIStackView(arrangedSubviews:  viewsList)
           vstackView.translatesAutoresizingMaskIntoConstraints = false
           vstackView.distribution = .fillProportionally
           vstackView.axis = .vertical
           scrollView.addSubview(vstackView)
           
           vstackView.backgroundColor = .red
           
           NSLayoutConstraint.activate([
               vstackView.topAnchor.constraint(equalTo:
                   scrollView.topAnchor
               ),
               
               
               vstackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor
               ),
               
               vstackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor
               ),
               
               vstackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
               
               vstackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
               
               //              vstackView.heightAnchor.constraint(equalToConstant: 2000)
               
               
               
           ])
           
       }
}

