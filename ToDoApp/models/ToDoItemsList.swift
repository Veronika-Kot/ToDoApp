//
//  ToDoItemsList.swift - Singleton for saving lists of done and
//                        undone tasks
//  ToDoApp
//
//  Created by Veronika Kotckovich on 11/27/19.
//  Copyright © 2019 Centennial College. All rights reserved.
//  Student ID: 301067511

import Foundation
import UIKit

class ToDoItemList {
    
    // Private variables
    private(set) var itemList:[ToDoItem]
    private(set) var doneItemList:[ToDoItem]
    
    public static func getInstance()-> ToDoItemList
    {
        return _instance
    }
    
    // private default constractor
    private init()
    {
        itemList = []
        doneItemList = []
    }
    
    // getting instance of this class
    private static var _instance:ToDoItemList =
    {
        let toDoList = ToDoItemList()
        
        return toDoList
    }()
    
    //Add item to appropriate list, based on "done" status
    func addItem(_ item: ToDoItem, _ done: Bool) -> Void
    {
        if done {
             doneItemList.append(item)
        } else {
            itemList.append(item)
        }
    }
    
    //Remove item from the appropriate list, based on "done" status
    func removeItem(_ index: Int, _ done: Bool) -> Void
    {
        if done {
            doneItemList.remove(at: index)
        } else {
            itemList.remove(at: index)
        }
    }
    
    //Return item from the appropriate list, based on "done" status
    func getItem(_ index: Int, _ done: Bool) -> ToDoItem
    {
        if done {
           return doneItemList[index]
        } else {
           return itemList[index]
        }
    }
}

