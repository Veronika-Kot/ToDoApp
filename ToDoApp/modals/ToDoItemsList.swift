//
//  ToDoItemsList.swift
//  ToDoApp
//
//  Created by Veronika Kotckovich on 11/27/19.
//  Copyright © 2019 Centennial College. All rights reserved.
//

import Foundation
import UIKit

class ToDoItemList {
    
    private(set) var itemList:[ToDoItem]
    private(set) var doneItemList:[ToDoItem]
    
    public static func getInstance()-> ToDoItemList
    {
        return _instance
    }
    
    private init() //private constractor
    {
        itemList = []
        doneItemList = []
    }
    
    private static var _instance:ToDoItemList =
    {
        let toDoList = ToDoItemList()
        
        return toDoList
    }()
    
    
    func addItem(_ item: ToDoItem, _ done: Bool) -> Void
    {
        if done {
             doneItemList.append(item)
        } else {
            itemList.append(item)
        }
    }
    
    func removeItem(_ index: Int, _ done: Bool) -> Void
    {
        if done {
            doneItemList.remove(at: index)
        } else {
            itemList.remove(at: index)
        }
    }
    
    func getItem(_ index: Int, _ done: Bool) -> ToDoItem
    {
        if done {
           return doneItemList[index]
        } else {
           return itemList[index]
        }
    }
}

