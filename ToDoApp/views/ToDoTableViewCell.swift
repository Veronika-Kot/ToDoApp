//
//  ToDoTableViewCell.swift
//  ToDoApp
//
//  Created by Veronika Kotckovich on 10/30/19.
//  Copyright © 2019 Centennial College. All rights reserved.
//

import UIKit

class ToDoTableViewCell: UITableViewCell {

    var toDoIem: ToDoItem = ToDoItem()
    @IBOutlet weak var toDoItemName: UILabel!
    @IBOutlet weak var toDoDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        statusSwitch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func greyOut(){
        toDoItemName.textColor = .gray
        toDoDate.textColor = .lightGray
    }
    
    func colorOut(){
        toDoItemName.textColor =  UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1)
        toDoDate.textColor = UIColor(red: 76/255, green: 175/255, blue: 80/255, alpha: 1)
    }
    
    
    
//    @objc func switchChanged(mySwitch: UISwitch) {
//        let alert = UIAlertController(title: "Are you sure?", message: "Do you want't to complete the task?", preferredStyle: .alert)
//        
//        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
//            print("YES, COMPLETE")
//        }))
//        
//        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
//            self.statusSwitch.isOn = !((self.statusSwitch?.state) != nil) ?? false
//        }))
//        
//        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
//    }
    
    
}
