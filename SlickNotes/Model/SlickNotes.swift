//
//  SlickNotes.swift
//  SlickNotes
//
//  Created by user166476 on 6/19/20.
//  Copyright © 2020 Quasars. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class SlickNotes {
    private(set) var noteId        : UUID
    private(set) var noteTitle     : String
    private(set) var noteText      : String
    private(set) var noteTimeStamp : Int64
    private(set) var latitude : String
    private(set) var longitude : String
    private(set) var location : String
    private(set) var category : Category?
    private(set) var texts: [String]
    private(set) var viewOrder: [String]
    private(set) var images: [String]
    
    init(noteTitle:String, noteText:String, noteTimeStamp:Int64, latitude: String, longitude: String, location:String, category: String = "all",texts :[String], viewOrder: [String], images: [String]) {
        self.noteId        = UUID()
        self.noteTitle     = noteTitle
        self.noteText      = noteText
        self.noteTimeStamp = noteTimeStamp
        self.latitude = latitude
        self.longitude = longitude
        self.location = location
        self.texts = texts
        self.viewOrder = viewOrder
        self.images = images
        let predicate = NSPredicate(format: "categoryName = %@", category as CVarArg)
        
         let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = predicate
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            let categories  = try context.fetch(request)
            if categories.count > 0 {
                 let category = categories[0]
                self.category = category
            }
           
        } catch {
            print("Error loading categories \(error.localizedDescription)")
        }
       
    }

    init(noteId: UUID, noteTitle:String, noteText:String, noteTimeStamp:Int64, latitude: String, longitude: String, location: String, category: String = "all", texts :[String], viewOrder: [String], images: [String]
    ) {
        self.noteId        = noteId
        self.noteTitle     = noteTitle
        self.noteText      = noteText
        self.noteTimeStamp = noteTimeStamp
        self.latitude = latitude
       self.longitude = longitude
        self.location = location
        self.texts = texts
       self.viewOrder = viewOrder
        self.images = images
        
        let predicate = NSPredicate(format: "categoryName = %@", category as CVarArg)
               
                let request: NSFetchRequest<Category> = Category.fetchRequest()
               request.predicate = predicate
               let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
               do {
                   let categories  = try context.fetch(request)
                   if categories.count > 0 {
                        let category = categories[0]
                       self.category = category
                   }
                  
               } catch {
                   print("Error loading categories \(error.localizedDescription)")
               }
        
    }
}
