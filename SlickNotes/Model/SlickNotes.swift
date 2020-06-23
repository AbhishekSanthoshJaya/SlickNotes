//
//  SlickNotes.swift
//  SlickNotes
//
//  Created by user166476 on 6/19/20.
//  Copyright © 2020 Quasars. All rights reserved.
//

import Foundation

class SlickNotes {
    private(set) var noteId        : UUID
    private(set) var noteTitle     : String
    private(set) var noteText      : String
    private(set) var noteTimeStamp : Int64
    private(set) var latitude : String
    private(set) var longitude : String
    private(set) var location : String
    private(set) var category : SlickCategory?

    
    init(noteTitle:String, noteText:String, noteTimeStamp:Int64, latitude: String, longitude: String, location:String, category: String = "all") {
        self.noteId        = UUID()
        self.noteTitle     = noteTitle
        self.noteText      = noteText
        self.noteTimeStamp = noteTimeStamp
        self.latitude = latitude
        self.longitude = longitude
        self.location = location
        
        let predicate = NSPredicate(format: "categoryName = %@", category as CVarArg)
        if let selectedCategories = SlickCategoryStorage.storage.readCategories(withPredicate: predicate){
            if selectedCategories.count > 0{
                self.category = selectedCategories[0]
            }
        }
        
    }

    init(noteId: UUID, noteTitle:String, noteText:String, noteTimeStamp:Int64, latitude: String, longitude: String, location: String, category: String = "all"
    ) {
        self.noteId        = noteId
        self.noteTitle     = noteTitle
        self.noteText      = noteText
        self.noteTimeStamp = noteTimeStamp
        self.latitude = latitude
       self.longitude = longitude
        self.location = location
        
        let predicate = NSPredicate(format: "categoryName = %@", category as CVarArg)
        if let selectedCategories = SlickCategoryStorage.storage.readCategories(withPredicate: predicate){
            
            if selectedCategories.count > 0{
                self.category = selectedCategories[0]
            }
            
        }
        
    }
}
