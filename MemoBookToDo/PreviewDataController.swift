//
//  PreviewDataController.swift
//  MemoBookToDo
//
//  Created by Derek Howes on 4/10/23.
//

import CoreData
import Foundation

class PreviewDataController {
    private let container = NSPersistentContainer(name: "MemoBook")

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    init() {
        container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")

        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
    
    func savePreviewData() -> ListItem{
        let item = ListItem(context: container.viewContext)
        item.completed = false
        item.dateCreated = Date()
        item.name = "A really really long name that will take multiple lines to write Out"
        item.priority = Int16(2)
            
        return item
    }
    
}
