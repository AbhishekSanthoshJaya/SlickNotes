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

    
    init(noteTitle:String, noteText:String, noteTimeStamp:Int64, latitude: String, longitude: String) {
        self.noteId        = UUID()
        self.noteTitle     = noteTitle
        self.noteText      = noteText
        self.noteTimeStamp = noteTimeStamp
        self.latitude = latitude
        self.longitude = longitude
    }

    init(noteId: UUID, noteTitle:String, noteText:String, noteTimeStamp:Int64, latitude: String, longitude: String) {
        self.noteId        = noteId
        self.noteTitle     = noteTitle
        self.noteText      = noteText
        self.noteTimeStamp = noteTimeStamp
        self.latitude = latitude
       self.longitude = longitude
    }
}
