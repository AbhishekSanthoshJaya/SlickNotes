//
//  SlickNoteCreatorViewController.swift
//  SlickNotes
//
//  Created by user166476 on 6/20/20.
//  Copyright © 2020 Quasars. All rights reserved.
//

import UIKit
import MapKit
import AVFoundation
import CoreData


class SlickCreateNoteViewController : UIViewController, UINavigationControllerDelegate,  UIImagePickerControllerDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate, SendRecordingBack {
    
    var managedContext: NSManagedObjectContext!
    let locationManager = CLLocationManager()
    var userLocation: CLLocation!
    let categoryPicker = UIPickerView()

    
   
    
    
    // UI elements
    var scrollView: UIScrollView! = nil
    var vstackView:UIStackView! = nil
    var viewsList: [UIView] = []
    var imagePicker: ImagePicker!
    var currentView: UIView!
    var textViewTitle: UITextView!
    var categoryTextField: UITextField!
    var noteDateLabel: UITextField!
    var audioFileNames: [String] = []
    
    var isEditMode: Bool = false
    
    func sendRecordingInfo(audioNames: [String]) {
        audioFileNames = audioFileNames + audioNames
        print("data Came back \(audioFileNames)")
        if currentView == nil{
            currentView = viewsList[viewsList.endIndex-1]
        }
               
        self.addAudioView(belowView: currentView , audioNames: audioNames)
    }
    
    
    private let noteCreationTimeStamp : Int64 = Date().toSeconds()
    var changingReallySimpleNote : SlickNotes? {
        didSet{
            isEditMode = true
        }
    }
    var folderSelectedName: String?
    
    // MARK: note tile changed
    @IBAction func noteTitleChanged(_ sender: UITextField, forEvent event: UIEvent) {
//        if self.changingReallySimpleNote != nil {
//            // change mode
//            noteDoneButton.isEnabled = true
//        } else {
//            // create mode
//            if ( sender.text?.isEmpty ?? true ) || ( noteTextTextView.text?.isEmpty ?? true ) {
//                noteDoneButton.isEnabled = false
//            } else {
//                noteDoneButton.isEnabled = true
//            }
//        }
    }
    
    

    
    // MARK: Changing Simple Note
    func setChangingReallySimpleNote(changingReallySimpleNote : SlickNotes) {
        self.changingReallySimpleNote = changingReallySimpleNote
    }
    
    private func getAllTextInfo() -> (String , [String]){
        
        var all_text = ""
        var textList = [String]()
        
        viewsList.forEach { (view) in
            if let textView = view as? UITextView{
                all_text = all_text + " " + textView.text
            }
           
        }
        
        viewsList[4...].forEach { (view) in
            if let textView = view as? UITextView{
                textList.append(textView.text)
            }
           
        }
        return (all_text, textList)
        
    }
    
    private func getViewOrder() -> [String]{
        var viewOrder = [String]()
        viewsList[4...].forEach { (view) in
            if view is UITextView{
                viewOrder.append("textView")
           }
            else if view is UIImageView{
                viewOrder.append("imageView")
            }
           else{
                viewOrder.append("audioView")
            }
       }
        return viewOrder
    }
    
    
    private func saveImage(data : Data, id: String) {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let imageInstance = Image(context: context)
        imageInstance.img = data
        imageInstance.id = id
        do {
            try context.save()
            print("Image is saved")
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    private func getAllImagesInfo() -> [String]{
        var images = [String]()
        viewsList[4...].forEach { (view) in
             if let iamgeView = view as? UIImageView{
                 let imageData = iamgeView.image?.pngData()
                 print(imageData)
                var id = UUID().uuidString
                images.append(id)
                saveImage(data: imageData!, id: id)
            }
        }
        return images
        
    }
    
    // MARK: addItem
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

                let (allText, textList) = self.getAllTextInfo()
                
                let imagesList = self.getAllImagesInfo()
                
                let note = SlickNotes(
                    noteTitle:     self.textViewTitle.text,
                    noteText:      allText,
                    noteTimeStamp: self.noteCreationTimeStamp,
                    latitude: String(self.userLocation.coordinate.latitude),
                    longitude: String(self.userLocation.coordinate.longitude),
                    location: location,
                    category: self.categoryTextField.text!,
                    texts: textList,
                    viewOrder: self.getViewOrder(),
                    images:imagesList
                    
                )


                SlickNotesStorage.storage.addNote(noteToBeAdded: note)


                // pop to lister
                self.navigationController?.popToRootViewController(animated: true)



            }

        }
        
    }
    
    // MARK: changeItem
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


                    let (allText, textList) = self.getAllTextInfo()
                    
                    let imagesList = self.getAllImagesInfo()
                    
                    let note = SlickNotes(noteId: changingReallySimpleNote.noteId,
                        noteTitle:     self.textViewTitle.text,
                        noteText:      allText,
                        noteTimeStamp: self.noteCreationTimeStamp,
                        latitude: String(self.userLocation.coordinate.latitude),
                        longitude: String(self.userLocation.coordinate.longitude),
                        location: location,
                        category: self.categoryTextField.text!,
                        texts: textList,
                        viewOrder: self.getViewOrder(),
                        images:imagesList
                        
                    )


                    SlickNotesStorage.storage.changeNote(noteToBeChanged: note)

                    self.navigationController?.popViewController(animated: true)


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
    
    
    func createTextView(textIndex: Int) -> UITextView{
        if let detail = changingReallySimpleNote{
            
            var text1 = detail.texts[textIndex]
            print(text1)
            
            let textView1 = UITextView()
            textView1.text = text1
            textView1.textAlignment = .center
            textView1.heightAnchor.constraint(equalToConstant: 200).isActive = true
            textView1.delegate = self
            textView1.isScrollEnabled = false
            textView1.font = UIFont.preferredFont(forTextStyle: .headline)
            textViewDidChange(textView1)
            return textView1
        }
        return UITextView()
    }
    
    func createImageView(imageId: String) -> UIImageView{
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let request: NSFetchRequest<Image> = Image.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", imageId as! CVarArg)
        var image: Image? = nil
        do {
            let images = try context.fetch(request)
            if images.count > 0 {
                print(images[0])
                image = images[0]
            }
            
        } catch {
            print("Error loading folders \(error.localizedDescription)")
        }
        
        
        let imageViewNew = UIImageView(image: UIImage(data: (image?.img)!))
        let size = CGSize(width: view.frame.width, height: .infinity)
        imageViewNew.heightAnchor.constraint(equalToConstant:
        imageViewNew.sizeThatFits(size).height).isActive = true
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
                swipeLeft.direction = .left
        imageViewNew.addGestureRecognizer(swipeLeft)
         imageViewNew.isUserInteractionEnabled = true
        return imageViewNew
    }
    
    func addExtaViews(){
        var textIndex = 0
        var imageIndex = 0
        var audioIndex = 0
        if let detail = changingReallySimpleNote{
            for viewType in detail.viewOrder{
                if viewType  == "textView"{
                    var textViewNew = createTextView(textIndex:textIndex)
                    print("DEbug:  " + textViewNew.text)
                    viewsList.append(textViewNew)
                    
                    
                    textIndex += 1
                }
                else if viewType == "imageView"{
                    var imageViewNew = createImageView(imageId: detail.images[imageIndex])
                    
                    

                  
                    viewsList.append(imageViewNew)
                    
                    imageIndex += 1
                }
                else{
                    //                    var audioView = createAudioView(audioIndex)
                    //                    audioIndex += 1
                }
                
            }
            
        }
     
    }
    
    
    func setUpView(){
        
        
        // clear layout
        
        if scrollView != nil {
             scrollView.removeFromSuperview()
        }
        
        // Add title
        
        textViewTitle = UITextView()
        
        if changingReallySimpleNote == nil {
            textViewTitle.text = "Enter Title"
            textViewTitle.textColor = UIColor.lightGray
        }
        else{
            textViewTitle.text = changingReallySimpleNote?.noteTitle

        }
      
        textViewTitle.textAlignment = .center
        viewsList.append(textViewTitle)
       
       textViewTitle.heightAnchor.constraint(equalToConstant: 20).isActive = true
       textViewTitle.delegate = self
       textViewTitle.isScrollEnabled = false
        textViewTitle.font = UIFont.preferredFont(forTextStyle: .largeTitle)
       textViewDidChange(textViewTitle)
        
        // Add date
        noteDateLabel =  UITextField()
        noteDateLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        noteDateLabel.textAlignment = .center
        viewsList.append(noteDateLabel)

        
        
        // Add a horizontal line
        let hr = UIView()
        hr.backgroundColor = .black
        hr.translatesAutoresizingMaskIntoConstraints = false
        hr.heightAnchor.constraint(equalToConstant: 50)
        hr.widthAnchor.constraint(equalToConstant: 50)
        viewsList.append(hr)

        
        
        // Add category
        
        let categoryLabel = UILabel()
        categoryLabel.text = "Category: "
        categoryLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        categoryLabel.textAlignment = .right
        
        
        
        categoryTextField = UITextField()
        categoryTextField.inputView = categoryPicker
        categoryTextField.text = folderSelectedName
        categoryTextField.textAlignment = .left
        categoryTextField.font = UIFont.preferredFont(forTextStyle: .headline)
        
    
        
        let hStack = UIStackView(arrangedSubviews: [ categoryLabel,categoryTextField])
        hStack.distribution = .fillEqually
        hStack.alignment = .center
        viewsList.append(hStack)

        
        
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
        
        if changingReallySimpleNote == nil {
            viewsList.append(textView1)
        }
        
        addExtaViews()
        
       
        
        // add scroll view and vertical stack
        scrollView = UIScrollView()
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
        
        
       
        vstackView = UIStackView(arrangedSubviews:  viewsList)
        for view in viewsList{
            vstackView.setCustomSpacing(10, after: view)
        }
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
    @IBAction func saveNoteBtnDown(_ sender: Any) {
        
        if self.changingReallySimpleNote != nil {
                  // change mode - change the item
                  changeItem()
              } else {
                  // create mode - create the item
                  addItem()
              }
    }
    
   
    
    @IBAction func saveAudioBtnDown(_ sender: Any) {
        let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let RecordViewController = storyBoard.instantiateViewController(withIdentifier: "RecordViewController") as! RecordViewController
        
        RecordViewController.delegate = self
        self.navigationController?.pushViewController(RecordViewController, animated: true)
       
        
    }
    @IBAction func saveImageBtnDown(_ sender: Any) {
        
         self.imagePicker.present(from: self.view)
    }
    
    
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        let alert = UIAlertController(
            title: "Confirm Delete",
            message: "",
            preferredStyle: .alert)
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(alert: UIAlertAction!) in
               print("Cancelled")
        })
        
        let okAction = UIAlertAction(title: "Delete", style: .destructive, handler: {(alert: UIAlertAction!) in
             if let viewSwipped = gesture.view{
                self.viewsList.remove(at: self.viewsList.index(of: viewSwipped)!)
                     viewSwipped.removeFromSuperview()
                 }
        })
        
        // add OK action
        alert.addAction(cancelAction)
        alert.addAction(okAction)

        // show alert
        self.present(alert, animated: true)
    
        
      
       
    }
    
    // MARK: didLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                   // create alert
                   let alert = UIAlertController(
                       title: "Could note get app delegate",
                       message: "Could note get app delegate, unexpected error occurred. Try again later.",
                       preferredStyle: .alert)
                   
                   // add OK action
                   alert.addAction(UIAlertAction(title: "OK",
                                                 style: .default))
                   // show alert
                   self.present(alert, animated: true)
                   return
                   
               }
        managedContext = appDelegate.persistentContainer.viewContext
               
                // set context in the storage
        SlickCategoryStorage.storage.setManagedContext(managedObjectContext: managedContext)
            
        
        
        setUpView()
        

        
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        
        categoryPicker.delegate = self

        
        // Add delegate
        locationManager.delegate = self
        
        // request permission
        locationManager.requestWhenInUseAuthorization()
        
        // update map info
        locationManager.startUpdatingLocation()
        
        // check if we are in create mode or in change mode
        if let changingReallySimpleNote = self.changingReallySimpleNote {
            // in change mode: initialize for fields with data coming from note to be changed
           
            textViewTitle.text = changingReallySimpleNote.noteTitle
//            noteTitleTextField.text = changingReallySimpleNote.noteTitle
            // enable done button by default
//            noteDoneButton.isEnabled = true
            
            
            let request: NSFetchRequest<Note> = Note.fetchRequest()
            request.predicate = NSPredicate(format: "noteId = %@", changingReallySimpleNote.noteId as! CVarArg)
            var note: Note? = nil
            do {
                let notes = try self.managedContext.fetch(request)
                if notes.count > 0 {
                    note = notes[0]
                }
                
            } catch {
                print("Error loading folders \(error.localizedDescription)")
            }
            
            if note != nil {
                categoryTextField.text = note?.parent?.categoryName ?? "All"
            }
            else{
                categoryTextField.text = "All"
            }
            
        } else {
            // in create mode: set initial time stamp label
            noteDateLabel.text = SlickNotesDateHelper.convertDate(date: Date.init(seconds: noteCreationTimeStamp))
        }
        
        // initialize text view UI - border width, radius and color
//        noteTextTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
//        noteTextTextView.layer.borderWidth = 1.0
//        noteTextTextView.layer.cornerRadius = 5
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        // For back button in navigation bar, change text
//        let backButton = UIBarButtonItem()
//        backButton.title = "Back"
//        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    // MARK: dismissKeyBoard
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    
    
    
    
}


// MARK extension CLLocationManager
extension SlickCreateNoteViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0]
        
        
    }
}





extension SlickCreateNoteViewController:  UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let categories = SlickCategoryStorage.storage.readCategories(){
            return categories.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if let categories = SlickCategoryStorage.storage.readCategories(){
            return categories[row].categoryName
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let categories = SlickCategoryStorage.storage.readCategories(){
            categoryTextField.text = categories[row].categoryName
        }
    }
}




// text view customization
extension SlickCreateNoteViewController: UITextViewDelegate{
    
    
    func textViewDidChange(_ textView: UITextView) {
        
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
        
//        if self.changingReallySimpleNote != nil {
//            // change mode
//            noteDoneButton.isEnabled = true
//        } else {
//            // create mode
//            if ( noteTitleTextField.text?.isEmpty ?? true ) || ( textView.text?.isEmpty ?? true ) {
//                noteDoneButton.isEnabled = false
//            } else {
//                noteDoneButton.isEnabled = true
//            }
//        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        currentView = textView
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            
            if textView == textViewTitle{
                textView.text = "Enter Title"
            }
            else{
                textView.text = "Enter Description"

            }
            
            textView.textColor = UIColor.lightGray
        }
    }
    
    
    
    
    
}


extension SlickCreateNoteViewController: ImagePickerDelegate{
    
    func addImageView(belowView: UIView, image: UIImage){
        var vStackSubViews = viewsList
        
        for view in vStackSubViews{
            if view == belowView{
                
                // add image view below.
                let imageViewNew = UIImageView(image: image)
                let size = CGSize(width: view.frame.width, height: .infinity)
                imageViewNew.heightAnchor.constraint(equalToConstant:
                imageViewNew.sizeThatFits(size).height).isActive = true
                let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
                        swipeLeft.direction = .left
                imageViewNew.addGestureRecognizer(swipeLeft)
                 imageViewNew.isUserInteractionEnabled = true
                
                
                viewsList.insert(imageViewNew, at: viewsList.firstIndex(of: view)! + 1)
                
                if(viewsList.firstIndex(of: imageViewNew) != (viewsList.endIndex - 1)){
                    
                    let nextView = viewsList[viewsList.firstIndex(of: imageViewNew)! + 1]
                    if let nextView2 = nextView as? UITextView{
                        print("next view is textView so skipping")
                    }
                    else{
                        let textViewNew = UITextView()
                                  textViewNew.heightAnchor.constraint(equalToConstant: 30).isActive = true
                                  textViewNew.delegate = self
                                  textViewNew.isScrollEnabled = false
                                textViewNew.font = UIFont.preferredFont(forTextStyle: .headline)

                                  viewsList.insert(textViewNew, at: viewsList.firstIndex(of: imageViewNew)! + 1)
                    }
                }
                else
                    {
                        let textViewNew = UITextView()
                        textViewNew.heightAnchor.constraint(equalToConstant: 30).isActive = true
                        textViewNew.delegate = self
                        textViewNew.isScrollEnabled = false
                        textViewNew.font = UIFont.preferredFont(forTextStyle: .headline)
                        viewsList.insert(textViewNew, at: viewsList.firstIndex(of: imageViewNew)! + 1)
                        
                }
                    
   
                vstackView.removeAllArrangedSubviews()
                viewsList.forEach { (vw) in
                    vstackView.addArrangedSubview(vw)
                }
            }
        }
    }
    
    func didSelect(image: UIImage?) {
        print(image)
        print(currentView)
        
        if currentView == nil{
            currentView = viewsList[viewsList.endIndex-1]
        }
        
        
        self.addImageView(belowView: currentView, image: image!)
    }
    
    
}


extension UIStackView {
    
    func removeAllArrangedSubviews() {
        
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        
       
        
        // Remove the views from self
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}


extension SlickCreateNoteViewController {
    
    func addAudioView(belowView: UIView, audioNames: [String]){
         var vStackSubViews = viewsList
         
         for view in vStackSubViews{
             if view == belowView{
                 
                
                 // Add audioView
                var currIndex = 1
                var lastAddedAudioView: AudioPlayerView! = nil
                
                for audioFileName in audioNames{
                    let audioViewNew = AudioPlayerView()
                    audioViewNew.setFileName(audioName: audioFileName)
                    viewsList.insert(audioViewNew, at: viewsList.firstIndex(of: view)! + currIndex)
                    lastAddedAudioView = audioViewNew
                    currIndex += 1
                }
                
                if(viewsList.firstIndex(of: lastAddedAudioView) != (viewsList.endIndex - 1)){
                    
                    let nextView = viewsList[viewsList.firstIndex(of: lastAddedAudioView)! + 1]
                    if let nextView2 = nextView as? UITextView{
                        print("next view is textView so skipping")
                    }
                    else{
                        let textViewNew = UITextView()
                                  textViewNew.heightAnchor.constraint(equalToConstant: 30).isActive = true
                                  textViewNew.delegate = self
                                  textViewNew.isScrollEnabled = false
                                textViewNew.font = UIFont.preferredFont(forTextStyle: .headline)

                                  viewsList.insert(textViewNew, at: viewsList.firstIndex(of: lastAddedAudioView)! + 1)
                    }
                }
                else
                    {
                        let textViewNew = UITextView()
                        textViewNew.heightAnchor.constraint(equalToConstant: 30).isActive = true
                        textViewNew.delegate = self
                        textViewNew.isScrollEnabled = false
                        textViewNew.font = UIFont.preferredFont(forTextStyle: .headline)
                        viewsList.insert(textViewNew, at: viewsList.firstIndex(of: lastAddedAudioView)! + 1)
                        
                }
                vstackView.removeAllArrangedSubviews()
                viewsList.forEach { (vw) in
                    vstackView.addArrangedSubview(vw)
                    vstackView.setCustomSpacing(10, after: vw)
                }
    
             }
         }
     }
}
