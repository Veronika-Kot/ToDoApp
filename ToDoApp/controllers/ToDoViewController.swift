//
//  ToDoViewController.swift -- Used to display to do item list
//  ToDoApp
//
//  Created by Veronika Kotckovich on 10/30/19.
//  Student ID: 301067511
//  Copyright © 2019 Centennial College. All rights reserved.
//

import UIKit
import Firebase

class ToDoViewController: UITableViewController {
    
    var ref:DatabaseReference! // reference to Firebase DB
    var userID: String!        // global variable for Device ID
    var dateFormatter: DateFormatter!  // global variable for DateFormatter
    
    var toDoItems: ToDoItemList!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toDoItems = ToDoItemList.getInstance()
        
        //create date formater
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        
        //Getting device UUID, which will be used as userID
        userID = UIDevice.current.identifierForVendor?.uuidString
        
        // Getting DB reference
        ref = Database.database().reference()
        
        //Trying to get an instance of a user and his task list
        ref.child("users").child(userID!).child("tasks").observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Get user value
            var value = snapshot.value as? NSDictionary
            
            //If there is a value, get an array of taks
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
            //if value is nill, cretae a user with one default task
            } else {
                
                let dueDate = self.dateFormatter.string(from: Date())
                
                let anItem = ToDoItem("Your First Task", "Task Details", dueDate)
                self.toDoItems.addItem(anItem, false)
                
                let dbTask = self.ref.child("users").child(self.userID!).child("tasks").childByAutoId()
                dbTask.setValue(["name": anItem.name, "details": anItem.details, "status": false, "due": anItem.date])
                
            }
            
            //Reloading table data here, since that func is ASYNC
            self.tableView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
        
        //Set cell height automatically adjust to content
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
        
        // tableView.reloadData()
        
        //Clear unused cells
        tableView.tableFooterView = UIView()
    }
    
    //Reloading table every time view is shown
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //reloading data
        tableView.reloadData()
    }
    
    //Adding new toDo task
    @IBAction func addToDo(_ sender: Any) {
        
        //Creating an instance of ToDoItem with default values
        let dueDate = self.dateFormatter.string(from: Date())
        let anItem = ToDoItem("New Task", "Task Details", dueDate)
        
        //Creating a record in DB
        let dbTask = self.ref.child("users").child(self.userID!).child("tasks").childByAutoId()
        dbTask.setValue(["name": anItem.name, "details": anItem.details, "status": false, "due": anItem.date])
        anItem.id = dbTask.key!
        
        //Adding the new task to global array
        self.toDoItems.addItem(anItem, false)
        tableView.reloadData()
        
        //Select the last row
        let indexPath = IndexPath(row: toDoItems.itemList.count - 1, section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
        
        //perform segue
        performSegue(withIdentifier: "toDetailsController", sender: nil)
        
    }
    
    //Return numbers of sections, 0 - not done, 1 - done
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    //Set titles to sections
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0
        {
            return "To Do"
        } else {
            return "Done"
        }
    }
    
    //Return numbers of cell per section
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
    
    //Create a cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
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
        cell.toDoItemName.text = theItem.name == "" ? "Empty name" : theItem.name
        cell.toDoDate.text = theItem.date
        
        return cell
    }
    
    // Set true for table slide gestures
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //Right side action  -- Delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            
            // Show alert when Delete is clicked
            let alert = UIAlertController(title: "Are you sure?", message: "Do you want't to delete this task?", preferredStyle: .alert)
            
                    //Remove the toDo item
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                        var taskID = ""
                        
                        //Getting the task ID
                        switch (indexPath.section) {
                        case 0:
                            taskID = self.toDoItems.itemList[indexPath.row].id
                        case 1:
                            taskID = self.toDoItems.doneItemList[indexPath.row].id
                        default:
                            taskID = ""
                        }
                        
                        //Delete from DataBase
                        self.ref.child("users").child(self.userID!).child("tasks").child(taskID)
                            .removeValue { error, _ in
                                if (error != nil) { print(error?.localizedDescription) }
                        }
                        
                        //Remove from local array
                        self.toDoItems.removeItem(indexPath.row, Bool(indexPath.section as NSNumber))
                        
                        tableView.reloadData()
                    }))
            
                    // Don't do anything on "No" button pressed
                    alert.addAction(UIAlertAction(title: "No", style: .cancel))
    
            
            //Show the alert
            self.present(alert, animated: true)
            
        }
    }
    
    //Left side action -- done/undone
    override func tableView(_ tableView: UITableView,
                            leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let  doneAction = UIContextualAction(style: .normal, title:  "DONE", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            
            //Getting an item from the local storage
            var toDoIem = self.toDoItems.getItem(indexPath.row, Bool(indexPath.section as NSNumber))
            
            //Update task in DB
            let task =  self.ref.child("users").child(self.userID).child("tasks").child(toDoIem.id)
            task.setValue(["name": toDoIem.name, "details": toDoIem.details, "due": toDoIem.date, "status": !toDoIem.done])
            
            //Move from one section to another
            self.toDoItems.removeItem(indexPath.row, toDoIem.done)
            self.toDoItems.addItem(toDoIem, !toDoIem.done)
            
            //Setting the status to the opposite one
            toDoIem.done = !toDoIem.done
            tableView.reloadData()
            
            success(true)
        })
        
        //Set the correct title and color
        if(indexPath.section == 0) {
            doneAction.backgroundColor = UIColor(red: 76/255, green: 175/255, blue: 80/255, alpha: 1)
            doneAction.title = "DONE"
        } else {
            doneAction.backgroundColor =  UIColor(red: 230/255, green: 74/255, blue: 25/255, alpha: 1)
            doneAction.title = "UN-DONE"
        }
        
        return UISwipeActionsConfiguration(actions: [doneAction])
        
    }
    
    // Prepare data for segue to a selected item details view
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
