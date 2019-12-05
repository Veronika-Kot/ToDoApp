//
//  ToDoItem.swift -- Model for ToDoItem
//  ToDoApp
//
//  Created by Veronika Kotckovich on 10/30/19.
//  Student ID: 301067511
//  Copyright © 2019 Centennial College. All rights reserved.

import Foundation

class ToDoItem {
    
    //local variables
    var name: String = ""
    var details: String = ""
    var done: Bool = false
    var date: String
    var id: String
    
    // Default init
    init() {
        self.name = "To Do Item"
        self.details = "Details"
        self.date = "Empty Date"
        self.id = ""
    }
    
    init(_ n: String, _ det: String, _ date: String){
        self.name = n
        self.details = det
        self.date = date
        self.id = ""
    }
    
    init(_ id: String, _ n: String, _ det: String, _ date: String, _ status: Bool){
        self.name = n
        self.details = det
        self.date = date
        self.done = status
        self.id = id
    }
}
