//
//  DataController.swift
//  MemoBookToDo
//
//  Created by Derek Howes on 3/24/23.
//

import CoreData
import Foundation

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "MemoBook")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}
