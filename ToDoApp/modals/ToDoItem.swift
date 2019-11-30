//
//  ToDoItem.swift
//  ToDoApp
//
//  Created by Veronika Kotckovich on 11/2/19.
//  Copyright © 2019 Centennial College. All rights reserved.
//

import Foundation

class ToDoItem {
    
    var name: String = ""
    
    var details: String = ""
    var done: Bool = false
    var date: String
    var id: String
    
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
