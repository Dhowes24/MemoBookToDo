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
        @Published var initalLoad: Bool = true
        @Published var items: [ListItem] = []
        @Published var showTaskEditor: Bool = false
        
        init() {
            container = DataController().container
            fetchItems()
        }
        
        func addItem(name: String, priority: Int16) {
            let item = ListItem(context: container.viewContext)
            item.completed = false
            item.dateCreated = Date()
            item.name = name
            item.priority = priority

            saveData()
        }
        
        func deleteItem(_ item: ListItem) {
            container.viewContext.delete(item)
            saveData()
        }
        
        func fetchItems() {
            let request = NSFetchRequest<ListItem>(entityName: "ListItem")
            
            do {
                items = try container.viewContext.fetch(request)
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
    }
}
