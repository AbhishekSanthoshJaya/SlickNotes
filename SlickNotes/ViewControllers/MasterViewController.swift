//
//  MasterViewController.swift
//  SlickNotes
//
//  Created by user166476 on 6/19/20.
//  Copyright © 2020 Quasars. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [Any]()
    var managedContext: NSManagedObjectContext!
 
    var folderPredicate: NSPredicate?
    var folderSelectedName: String? {
        didSet{
            folderPredicate = NSPredicate(format: "parent.categoryName = %@", folderSelectedName as! CVarArg)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
//        self.view.addGestureRecognizer(tapGesture)
//        
         // Core data initialization
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
        SlickNotesStorage.storage.setManagedContext(managedObjectContext: managedContext)
        
        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }
    

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
//    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
//        self.view.endEditing(true)
//    }

    @objc
    func insertNewObject(_ sender: Any) {
        performSegue(withIdentifier: "showCreateNoteSegue", sender: self)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = SlickNotesStorage.storage.readNote(at: indexPath.row)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                detailViewController = controller
            }
        }
    }

    // MARK: - Table View
    


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if SlickNotesStorage.storage.count() == 0 {
        self.tableView.setEmptyMessage("No notes to show")
        } else {
        self.tableView.restore()
        }
        //return places?.count ?? 0
        
        
        return SlickNotesStorage.storage.readNotes(withPredicate: folderPredicate)!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SlickNotesTableCell

        let object = SlickNotesStorage.storage.readNotes(withPredicate: folderPredicate)![indexPath.row]
        cell.noteTitleLabel!.text = object.noteTitle
        cell.noteTextLabel!.text = object.noteText
            cell.noteDateLabel!.text = SlickNotesDateHelper.convertDate(date: Date.init(seconds: object.noteTimeStamp))
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //objects.remove(at: indexPath.row)
            SlickNotesStorage.storage.removeNote(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

