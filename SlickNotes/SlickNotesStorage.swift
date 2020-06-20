//
//  SlickNotesStorage.swift
//  SlickNotes
//
//  Created by user166476 on 6/19/20.
//  Copyright © 2020 Quasars. All rights reserved.
//

import UIKit
import CoreData

class SlickNotesStorage {
    static let storage : SlickNotesStorage = SlickNotesStorage()
    
    private var noteIndexToIdDict : [Int:UUID] = [:]
    private var currentIndex : Int = 0

    private(set) var managedObjectContext : NSManagedObjectContext
    private var managedContextHasBeenSet : Bool = false
    
    private init() {
        // we need to init our ManagedObjectContext
        // This will be overwritten when setManagedContext is called from the view controller.
        managedObjectContext = NSManagedObjectContext(
            concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)

    func setManagedContext(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        self.managedContextHasBeenSet = true
        let notes = SlickNotesCoreDataHelper.readNotesFromCoreData(fromManagedObjectContext: self.managedObjectContext)
        currentIndex = SlickNotesCoreDataHelper.count
        for (index, note) in notes.enumerated() {
            noteIndexToIdDict[index] = note.noteId
        }
    }
    }
    
    func addNote(noteToBeAdded: SlickNotes) {
        if managedContextHasBeenSet {
            // add note UUID to the dictionary
            noteIndexToIdDict[currentIndex] = noteToBeAdded.noteId
            SlickNotesCoreDataHelper.createNoteInCoreData(
                noteToBeCreated:          noteToBeAdded,
                intoManagedObjectContext: self.managedObjectContext)
            // increase index
            currentIndex += 1
        }
    }
    
    
}
