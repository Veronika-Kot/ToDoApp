//
//  DetailsViewController.swift -- used for updating the toDo item details
//  ToDoApp
//
//  Created by Veronika Kotckovich on 10/30/19.
//  Student ID: 301067511
//  Copyright © 2019 Centennial College. All rights reserved.
//

import UIKit
import Firebase

class DetailsViewController: UIViewController, UITextFieldDelegate {
    
    var ref:DatabaseReference!
    var userID: String!
    var toDoIem: ToDoItem = ToDoItem()
    var datePickerView:UIDatePicker?
    let dateFormatter = DateFormatter()
    
    var indexPath = -1
    
    var changedStatus = false
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var detailsTextView: UITextView!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var statusSwitch: UISwitch!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userID = UIDevice.current.identifierForVendor?.uuidString
        
        // Getting DB reference
        ref = Database.database().reference()
        
        // Setting values for UI elements
        nameTextField.text = toDoIem.name
        detailsTextView.text = toDoIem.details
        
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateField.text = toDoIem.date
        
        statusSwitch.setOn(toDoIem.done, animated: false)
        
        // Creating UIColors based on styleguide
        let lightPink = UIColor(red: 1, green: 201/255, blue: 188/255, alpha: 1)
        let darkPink = UIColor(red: 230/255, green: 74/255, blue: 25/255, alpha: 1)
        let green = UIColor(red: 76/255, green: 175/255, blue: 80/255, alpha: 1)
        
        // Creating borders for input fields and buttons
        detailsTextView.layer.borderWidth = 1
        detailsTextView.layer.borderColor = lightPink.cgColor
        detailsTextView.layer.cornerRadius = 5
        
        nameTextField.layer.borderWidth = 1
        nameTextField.layer.borderColor = lightPink.cgColor
        nameTextField.layer.cornerRadius = 5
        nameTextField.addPadding(.both(10))
        
        dateField.layer.borderWidth = 1
        dateField.layer.borderColor = lightPink.cgColor
        dateField.layer.cornerRadius = 5
        
        saveButton.setBorder(green)
        cancelButton.setBorder(green)
        deleteButton.setBorder(darkPink)
        
        // Add a target actions to a switch
        statusSwitch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        
        //textField delegets 
        nameTextField.delegate = self
        
        //Add a toolbar to DatePicker view with a target action
        let toolBar = UIToolbar().ToolbarPicker(selectDone: #selector(self.dismissKeyboard), selectToday: #selector(findToday))
        dateField.inputAccessoryView = toolBar
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        
        //Adding tap gesture for closing keyboards
        view.addGestureRecognizer(tap)
    }
    
    //Saving action
    @IBAction func onSave(_ sender: UIButton) {
        toDoIem.name = nameTextField.text ?? ""
        toDoIem.details = detailsTextView.text ?? ""
        toDoIem.date = dateField.text!
        toDoIem.done = statusSwitch.isOn
        
        //Update task in DB
        let task =  self.ref.child("users").child(self.userID).child("tasks").child(toDoIem.id)
        task.setValue(["name": toDoIem.name, "details": toDoIem.details, "status": toDoIem.done, "due": dateField.text!])
        
        //Move from one section to another if neccesary
        if changedStatus {
            ToDoItemList.getInstance().removeItem(indexPath, !statusSwitch.isOn)
            ToDoItemList.getInstance().addItem(toDoIem, statusSwitch.isOn)
        }
        
        // Return back to list controller
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    //Cancel action - just return back
    @IBAction func onCancel(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    //Delete action
    @IBAction func onDelete(_ sender: UIButton) {
        let taskID = toDoIem.id
        
        // Remove item from the DB
        self.ref.child("users").child(self.userID!).child("tasks").child(taskID)
            .removeValue { error, _ in
                if (error != nil) { print(error?.localizedDescription) }
        }
        
        // Remove from local array
        ToDoItemList.getInstance().removeItem(indexPath, toDoIem.done)
        
        // Go back to previous viewController
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    // TextField Delegate method to open Date picker view, when date-input is selected
    @IBAction func onDateBeginEditing(_ sender: UITextField) {
        datePickerView = UIDatePicker()
        datePickerView!.datePickerMode = .date
        sender.inputView = datePickerView
        
        datePickerView!.addTarget(self, action: #selector(datePickerChanged(picker:)), for: .valueChanged)
    }
    
    // TextField Delegate function fired when return key is pressed on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
    }
    
    // Target action - Set value to date-input, when date is selected
    @objc func datePickerChanged(picker: UIDatePicker){
        dateField.text = dateFormatter.string(from: picker.date)
    }
    
    // Target action - Action for Date Picker toolbar -- find today
    @objc func findToday() {
        datePickerView!.date = Date()
        dateField.text = dateFormatter.string(from:  Date())
    }
    
    // Target action - close keyboard when tapped somewhere-else on the screen
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Target action - on swtich change, setting status on opposite
    @objc func switchChanged(mySwitch: UISwitch) {
        changedStatus = !changedStatus
    }
}
//
// EXTENSIONS
//

// Extennion for setting colored border for buttons
extension UIButton {
    func setBorder(_ color: UIColor){
        self.layer.borderWidth = 1
        self.layer.borderColor = color.cgColor
        self.layer.cornerRadius = 5
    }
}

// Extennion for adding toolbar with Done and Today buttons
extension UIToolbar {
    func ToolbarPicker(selectDone: Selector, selectToday: Selector) -> UIToolbar{
        let toolBar = UIToolbar()
        
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: selectDone)
        let todayButton = UIBarButtonItem(title: "Today", style: .plain, target: self, action: selectToday)
        toolBar.setItems([todayButton, space, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        return toolBar
    }
}

// Extennion for padding to text field
extension UITextField {
    enum PaddingSide {
        case left(CGFloat)
        case right(CGFloat)
        case both(CGFloat)
    }
    
    func addPadding(_ padding: PaddingSide) {
        self.layer.masksToBounds = true
        
        switch padding {
        case .left(let spacing):
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
            self.leftView = paddingView
            self.rightViewMode = .always
            
        case .right(let spacing):
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
            self.rightView = paddingView
            self.rightViewMode = .always
            
        case .both(let spacing):
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
            // left
            self.leftView = paddingView
            self.leftViewMode = .always
            // right
            self.rightView = paddingView
            self.rightViewMode = .always
        }
    }
}
