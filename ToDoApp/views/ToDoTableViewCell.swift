//
//  ToDoTableViewCell.swift -- Custom cell view
//  ToDoApp
//
//  Created by Veronika Kotckovich on 10/30/19.
//  Copyright © 2019 Centennial College. All rights reserved.
//  Student ID: 301067511

import UIKit

class ToDoTableViewCell: UITableViewCell {

    var toDoIem: ToDoItem = ToDoItem()
    @IBOutlet weak var toDoItemName: UILabel!
    @IBOutlet weak var toDoDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // Set content text to grey
    func greyOut(){
        toDoItemName.textColor = .gray
        toDoDate.textColor = .lightGray
    }
    
     // Set content text to appropriate colors
    func colorOut(){
        toDoItemName.textColor =  UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1)
        toDoDate.textColor = UIColor(red: 76/255, green: 175/255, blue: 80/255, alpha: 1)
    }
}
