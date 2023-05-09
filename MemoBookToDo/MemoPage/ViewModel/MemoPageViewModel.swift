//
//  MemoPageViewModel.swift
//  MemoBookToDo
//
//  Created by Derek Howes on 4/8/23.
//

import Foundation
import SwiftUI
import CoreData

extension MemoPageView {
    @MainActor class MemoPageViewModel: ObservableObject {
        
        let container: NSPersistentContainer
        @Published var chooseDate: Bool = false
        @Published var date: Date = Date.now
        @Published var initalLoad: Bool = true
        @Published var items: [ListItem] = []
        @Published var showTaskEditor: Bool = false
        @Published var updatingTaskBool: Bool = false
        @Published var itemToUpdate: ListItem?
        
        init() {
            container = DataController().container
            fetchItems()
        }
        
        func addItem(name: String, ongoing: Bool,  priority: Int16, deadline: Date?) {
            let item = ListItem(context: container.viewContext)
            item.completed = false
            item.dateCreated = date
            item.name = name
            item.onGoing = ongoing
            item.priority = priority
            item.taskDeadline = deadline
            item.uuid = UUID()

            saveData()
        }
        
        func cleanUpCoreData() {
            let request = NSFetchRequest<ListItem>(entityName: "ListItem")
            
            do {
                let itemsToDelete = try container.viewContext.fetch(request).filter{ $0.dateCreated ?? Date.now < twoMonthsAgo }
                for item in itemsToDelete {
                    if (item.onGoing && item.dateCompleted ?? Date.now < twoMonthsAgo) || !item.onGoing {
                        deleteItem(item)
                    }
                }
            } catch let error {
                print("Error fetching. \(error)")
            }
        }
        
        func deleteItem(_ item: ListItem) {
            withAnimation(Animation.easeInOut(duration: 0.5)) {
                
                items.removeAll { listItem in
                    listItem.uuid == item.uuid
                }
            }
            container.viewContext.delete(item)
            saveData()
        }
        
        func fetchItems() {
            let request = NSFetchRequest<ListItem>(entityName: "ListItem")
            
            do {
                items = try container.viewContext.fetch(request).filter{
                    Calendar.current.numberOfDaysBetween($0.dateCreated ?? Date.distantFuture, and: date) == 0 ||
                    (Calendar.current.numberOfDaysBetween($0.dateCreated ?? Date.distantFuture, and: date) > 0 &&
                     $0.onGoing &&
                     Calendar.current.numberOfDaysBetween($0.dateCompleted ?? Date.distantFuture, and: date) <= 0)
                }
            } catch let error {
                print("Error fetching. \(error)")
            }
        }
        
        func resetCoreData() {
            for item in items  {
                container.viewContext.delete(item)
            }
            saveData()
        }
        
        func saveData() {
            do {
                try container.viewContext.save()
                fetchItems()
            } catch let error {
                print("Error Saving. \(error)")
            }
        }
        
        func updateItem(_ item: ListItem, name: String, ongoing: Bool,  priority: Int16, deadline: Date?) {
            item.completed = false
            item.name = name
            item.onGoing = ongoing
            item.priority = priority
            item.taskDeadline = deadline
            
            saveData()
        }
        
        func newLoad() {
            chooseDate = false
            initalLoad = true
            fetchItems()
        }
    }
}
