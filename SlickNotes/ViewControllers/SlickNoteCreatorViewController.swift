//
//  SlickNoteCreatorViewController.swift
//  SlickNotes
//
//  Created by user166476 on 6/20/20.
//  Copyright © 2020 Quasars. All rights reserved.
//

import UIKit
import MapKit

class SlickNoteCreatorViewController : UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var noteTitleTextField: UITextField!
    @IBOutlet weak var noteTextTextView: UITextView!
    @IBOutlet weak var noteDoneButton: UIButton!
    @IBOutlet weak var noteDateLabel: UILabel!
    let locationManager = CLLocationManager()
    var userLocation: CLLocation!

    private let noteCreationTimeStamp : Int64 = Date().toSeconds()
    private(set) var changingReallySimpleNote : SlickNotes?
    
    @IBAction func noteTitleChanged(_ sender: UITextField, forEvent event: UIEvent) {
        if self.changingReallySimpleNote != nil {
            // change mode
            noteDoneButton.isEnabled = true
        } else {
            // create mode
            if ( sender.text?.isEmpty ?? true ) || ( noteTextTextView.text?.isEmpty ?? true ) {
                noteDoneButton.isEnabled = false
            } else {
                noteDoneButton.isEnabled = true
            }
        }
    }
    
    @IBAction func doneButtonClicked(_ sender: UIButton, forEvent event: UIEvent) {
        // distinguish change mode and create mode
        if self.changingReallySimpleNote != nil {
            // change mode - change the item
            changeItem()
        } else {
            // create mode - create the item
            addItem()
        }
    }
    
    func setChangingReallySimpleNote(changingReallySimpleNote : SlickNotes) {
        self.changingReallySimpleNote = changingReallySimpleNote
    }
    
    

    
    private func addItem() -> Void {
        
        let lat = userLocation.coordinate.latitude
        let long  = userLocation.coordinate.longitude
        
        
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: lat, longitude: long)){
                   
                   placemark, error in
                   
                   
                   if let error = error as? CLError
                   {
                       print("CLError:", error)
                       return
                   }
                       
                   else if let placemark = placemark?[0]
                   {
                               
                       
                       var placeName = ""
                       var city = ""
                       var postalCode = ""
                       var country = ""
                       if let name = placemark.name { placeName += name }
                       if let locality = placemark.subLocality { city += locality }
                       if let code = placemark.postalCode { postalCode += code }
                       if let countryName = placemark.country { country += countryName }
                       
                       var location = "\(placeName), \(country)"
                       
                    
                        let note = SlickNotes(
                            noteTitle:     self.noteTitleTextField.text!,
                            noteText:      self.noteTextTextView.text,
                            noteTimeStamp: self.noteCreationTimeStamp,
                            latitude: String(self.userLocation.coordinate.latitude),
                            longitude: String(self.userLocation.coordinate.longitude),
                                   location: location
                                   )

                               SlickNotesStorage.storage.addNote(noteToBeAdded: note)
                               
                    self.performSegue(
                                   withIdentifier: "backToMasterView",
                                   sender: self)
                    }
                   
               }
       
    }

    private func changeItem() -> Void {
        // get changed note instance
        if let changingReallySimpleNote = self.changingReallySimpleNote {
            // change the note through note storage
            let lat = userLocation.coordinate.latitude
            let long  = userLocation.coordinate.longitude
            
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: lat, longitude: long)){
                         
                         placemark, error in
                         
                         
                         if let error = error as? CLError
                         {
                             print("CLError:", error)
                             return
                         }
                             
                         else if let placemark = placemark?[0]
                         {
                                     
                             
                             var placeName = ""
                             var city = ""
                             var postalCode = ""
                             var country = ""
                             if let name = placemark.name { placeName += name }
                             if let locality = placemark.subLocality { city += locality }
                             if let code = placemark.postalCode { postalCode += code }
                             if let countryName = placemark.country { country += countryName }
                             
                             var location = "\(placeName), \(country)"
                        
                            
                            SlickNotesStorage.storage.changeNote(
                                           noteToBeChanged: SlickNotes(
                                               noteId:        changingReallySimpleNote.noteId,
                                               noteTitle:     self.noteTitleTextField.text!,
                                               noteText:      self.noteTextTextView.text,
                                               noteTimeStamp: self.noteCreationTimeStamp,
                                               latitude: String(self.userLocation.coordinate.latitude),
                                               longitude: String(self.userLocation.coordinate.longitude),
                                               location: location
                                               )
                                       )
                                       // navigate back to list of notes
                            self.performSegue(
                                           withIdentifier: "backToMasterView",
                                           sender: self)
                
                
                        }
                
            }
            
            
           
        } else {
            // create alert
            let alert = UIAlertController(
                title: "Unexpected error",
                message: "Cannot change the note, unexpected error occurred. Try again later.",
                preferredStyle: .alert)
            
            // add OK action
            alert.addAction(UIAlertAction(title: "OK",
                                          style: .default ) { (_) in self.performSegue(
                                              withIdentifier: "backToMasterView",
                                              sender: self)})
            // show alert
            self.present(alert, animated: true)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set text view delegate so that we can react on text change
        noteTextTextView.delegate = self
        
        // Add delegate
        locationManager.delegate = self
        
        // request permission
        locationManager.requestWhenInUseAuthorization()
        
        // update map info
        locationManager.startUpdatingLocation()
        
        // check if we are in create mode or in change mode
        if let changingReallySimpleNote = self.changingReallySimpleNote {
            // in change mode: initialize for fields with data coming from note to be changed
            noteDateLabel.text = SlickNotesDateHelper.convertDate(date: Date.init(seconds: noteCreationTimeStamp))
            noteTextTextView.text = changingReallySimpleNote.noteText
            noteTitleTextField.text = changingReallySimpleNote.noteTitle
            // enable done button by default
            noteDoneButton.isEnabled = true
        } else {
            // in create mode: set initial time stamp label
            noteDateLabel.text = SlickNotesDateHelper.convertDate(date: Date.init(seconds: noteCreationTimeStamp))
        }
        
        // initialize text view UI - border width, radius and color
        noteTextTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        noteTextTextView.layer.borderWidth = 1.0
        noteTextTextView.layer.cornerRadius = 5
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")

    //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
    //tap.cancelsTouchesInView = false

        view.addGestureRecognizer(tap)
        
        // For back button in navigation bar, change text
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    @objc func dismissKeyboard() {
    //Causes the view (or one of its embedded text fields) to resign the first responder status.
    view.endEditing(true)
    }
    //Handle the text changes here
    func textViewDidChange(_ textView: UITextView) {
        if self.changingReallySimpleNote != nil {
            // change mode
            noteDoneButton.isEnabled = true
        } else {
            // create mode
            if ( noteTitleTextField.text?.isEmpty ?? true ) || ( textView.text?.isEmpty ?? true ) {
                noteDoneButton.isEnabled = false
            } else {
                noteDoneButton.isEnabled = true
            }
        }
    }

}


extension SlickNoteCreatorViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0]
        
        
    }
}
