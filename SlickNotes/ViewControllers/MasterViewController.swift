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
    
    
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var allNotes: [SlickNotes] = []
    var filteredNotes: [SlickNotes] = []
    
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        loadNotes()
        
        // code for searching
        searchController.searchResultsUpdater = self
        // 2
        searchController.obscuresBackgroundDuringPresentation = false
        // 3
        searchController.searchBar.placeholder = "Search Notes"
        // 4
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        // 5
        definesPresentationContext = true
        
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

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
       
    }
    
    
    func loadNotes(){
        if folderSelectedName == "All"{
                          folderPredicate = nil
        }
               
        allNotes = SlickNotesStorage.storage.readNotes(withPredicate: folderPredicate)!
    }

    override func viewWillAppear(_ animated: Bool) {
//        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        loadNotes()
        tableView.reloadData()

    }
    
//    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
//        self.view.endEditing(true)
//    }

//    @objc
//    func insertNewObject(_ sender: Any) {
//        let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
//        let SlickNoteCreatorViewController = storyBoard.instantiateViewController(withIdentifier: "SlickNoteCreatorViewController") as! SlickNoteCreatorViewController
//
//        SlickNoteCreatorViewController.folderSelectedName = folderSelectedName
//        self.navigationController?.pushViewController(SlickNoteCreatorViewController, animated: true)
//    }
    
    
    @objc
       func insertNewObject(_ sender: Any) {
           let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
           let SlickCreateNoteViewController = storyBoard.instantiateViewController(withIdentifier: "SlickCreateNoteViewController") as! SlickCreateNoteViewController
           
           SlickCreateNoteViewController.folderSelectedName = folderSelectedName
           self.navigationController?.pushViewController(SlickCreateNoteViewController, animated: true)
       }

    // MARK: - Segues

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showDetail" {
//            if let indexPath = tableView.indexPathForSelectedRow {
//                let object = SlickNotesStorage.storage.readNote(at: indexPath.row)
//                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
//                controller.detailItem = object
//                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
//                controller.navigationItem.leftItemsSupplementBackButton = true
//                detailViewController = controller
//            }
//        }
//    }

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
        
        if isFiltering {
          return filteredNotes.count
        }
        return allNotes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SlickNotesTableCell

        let object: SlickNotes
        if isFiltering {
            object = filteredNotes[indexPath.row]
        }
        else
        {
            object = allNotes[indexPath.row]
        }
        cell.noteTitleLabel!.text = object.noteTitle
        cell.noteTextLabel!.text = object.noteText
            cell.noteDateLabel!.text = SlickNotesDateHelper.convertDate(date: Date.init(seconds: object.noteTimeStamp))
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let object: SlickNotes
        if isFiltering {
            object = filteredNotes[indexPath.row]
        }
        else{
            object = allNotes[indexPath.row]
        }
        
        let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let NoteDetailViewController = storyBoard.instantiateViewController(withIdentifier: "NoteDetailViewController") as! NoteDetailViewController
        NoteDetailViewController.detailItem = object
        NoteDetailViewController.folderSelectedName = folderSelectedName
       self.navigationController?.pushViewController(NoteDetailViewController, animated: true)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //objects.remove(at: indexPath.row)
            
            var delIndex = 0
            for val in allNotes{
                if val.noteId == filteredNotes[indexPath.row].noteId
                {
                    break
                }
                delIndex = delIndex + 1
            }
            SlickNotesStorage.storage.removeNote(at: delIndex)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

extension MasterViewController: UISearchResultsUpdating {
      func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
      }
        
    func filterContentForSearchText(_ searchText: String
                                    ) {
      filteredNotes = allNotes.filter { (note: SlickNotes) -> Bool in
        return note.noteTitle.lowercased().contains(searchText.lowercased()) || note.noteText.lowercased().contains(searchText.lowercased()
        )
      }
      
      tableView.reloadData()
    }
}
