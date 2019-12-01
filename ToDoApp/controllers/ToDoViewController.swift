//
//  ViewController.swift
//  ToDoApp
//
//  Created by Veronika Kotckovich on 10/30/19.
//  Copyright © 2019 Centennial College. All rights reserved.
//

import UIKit
import Firebase

class ToDoViewController: UITableViewController {
    
    var ref:DatabaseReference!
    var userID: String!
    var dateFormatter: DateFormatter!
    
    var toDoItems: ToDoItemList!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toDoItems = ToDoItemList.getInstance()
        
        //create date formater
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        
        userID = UIDevice.current.identifierForVendor?.uuidString
        
        // Getting DB reference
        ref = Database.database().reference()
        
        ref.child("users").child(userID!).child("tasks").observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Get user value
            var value = snapshot.value as? NSDictionary
            
            if value != nil {
                if let snapDict = snapshot.value as? [String:AnyObject] {
                    for child in snapDict{
                        let shotKey = snapshot.children.nextObject() as! DataSnapshot
                        if let task = child.value as? [String:AnyObject]{
                            let _name = task["name"] as! String
                            let _details = task["details"] as! String
                            let _status = task["status"] as! Bool
                            let _due = task["due"] as! String
                            let _id = child.key
                            self.toDoItems.addItem(ToDoItem(_id, _name, _details, _due, _status), _status)
                        }
                    }
                }
            } else {
                
                let dueDate = self.dateFormatter.string(from: Date())
                
                let anItem = ToDoItem("Your First Task", "Task Details", dueDate)
                self.toDoItems.addItem(anItem, false)
                
                let dbTask = self.ref.child("users").child(self.userID!).child("tasks").childByAutoId()
                dbTask.setValue(["name": anItem.name, "details": anItem.details, "status": false, "due": anItem.date])
                
            }
            
            self.tableView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
        
        tableView.reloadData()
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //reloading data
        tableView.reloadData()
    }
    
    @IBAction func addToDo(_ sender: Any) {
        let dueDate = self.dateFormatter.string(from: Date())
        let anItem = ToDoItem("New Task", "Task Details", dueDate)
        
        let dbTask = self.ref.child("users").child(self.userID!).child("tasks").childByAutoId()
        dbTask.setValue(["name": anItem.name, "details": anItem.details, "status": false, "due": anItem.date])
        anItem.id = dbTask.key!
        
        self.toDoItems.addItem(anItem, false)
        tableView.reloadData()
        
        //Select the last row
        let indexPath = IndexPath(row: toDoItems.itemList.count - 1, section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
        
        //perform segue
        performSegue(withIdentifier: "toDetailsController", sender: nil)
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0
        {
            return "To Do"
        } else {
            return "Done"
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch (section) {
        case 0:
            return toDoItems.itemList.count
        case 1:
            return toDoItems.doneItemList.count
        default:
            return 0
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItem", for: indexPath) as! ToDoTableViewCell
        
        var theItem: ToDoItem!
        
        switch (indexPath.section) {
        case 0:
            theItem = toDoItems.itemList[indexPath.row]
            cell.colorOut()
        case 1:
            theItem = toDoItems.doneItemList[indexPath.row]
            cell.greyOut()
        default:
            theItem = ToDoItem()
        }
        
        cell.toDoIem = theItem
        cell.toDoItemName.text = theItem.name
        cell.toDoDate.text = theItem.date
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //right side action delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            
            let alert = UIAlertController(title: "Are you sure?", message: "Do you want't to delete this task?", preferredStyle: .alert)
            
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                        
                        var taskID = ""
                        switch (indexPath.section) {
                        case 0:
                            taskID = self.toDoItems.itemList[indexPath.row].id
                        case 1:
                            taskID = self.toDoItems.doneItemList[indexPath.row].id
                        default:
                            taskID = ""
                        }
                        self.ref.child("users").child(self.userID!).child("tasks").child(taskID)
                            .removeValue { error, _ in
                                if (error != nil) { print(error?.localizedDescription) }
                        }
                        
                        //remove from local array
                        self.toDoItems.removeItem(indexPath.row, Bool(indexPath.section as NSNumber))
                        
                        tableView.reloadData()
                    }))
            
                    alert.addAction(UIAlertAction(title: "No", style: .cancel))
    
            
            self.present(alert, animated: true)
            
        }
    }
    
    //left side action done/undone
    override func tableView(_ tableView: UITableView,
                            leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let  doneAction = UIContextualAction(style: .normal, title:  "DONE", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            
            var toDoIem = self.toDoItems.getItem(indexPath.row, Bool(indexPath.section as NSNumber))
            
            //Update task in DB
            let task =  self.ref.child("users").child(self.userID).child("tasks").child(toDoIem.id)
            task.setValue(["name": toDoIem.name, "details": toDoIem.details, "due": toDoIem.date, "status": !toDoIem.done])
            
            //Move from one section to another
            self.toDoItems.removeItem(indexPath.row, toDoIem.done)
            self.toDoItems.addItem(toDoIem, !toDoIem.done)
            
            toDoIem.done = !toDoIem.done
            tableView.reloadData()
            
            success(true)
        })
        
        if(indexPath.section == 0) {
            doneAction.backgroundColor = UIColor(red: 76/255, green: 175/255, blue: 80/255, alpha: 1)
            doneAction.title = "DONE"
        } else {
            doneAction.backgroundColor =  UIColor(red: 230/255, green: 74/255, blue: 25/255, alpha: 1)
            doneAction.title = "UN-DONE"
        }
        
        return UISwipeActionsConfiguration(actions: [doneAction])
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "toDetailsController",
            let destination = segue.destination as? DetailsViewController,
            let itemIndex = tableView.indexPathForSelectedRow?.row,
            let sectionIndex = tableView.indexPathForSelectedRow?.section
        {
            if(sectionIndex == 0){
                destination.toDoIem = toDoItems.itemList[itemIndex]
            } else {
                destination.toDoIem = toDoItems.doneItemList[itemIndex]
            }
            
            destination.indexPath = itemIndex
        }
    }
}
