//
//  MemoPageViewModel.swift
//  MemoBookToDo
//
//  Created by Derek Howes on 4/8/23.
//

import Foundation
import SwiftUI
import CoreData

class MemoPageViewModel: ObservableObject {
    
    let mainContext: NSManagedObjectContext
    
    @Published var chooseDate: Bool = false
    @Published var date: Date = Date.now
    @Published var initalLoad: Bool = true
    @Published var items: [ListItem] = []
    @Published var showTaskEditor: Bool = false
    @Published var updatingTaskBool: Bool = false
    @Published var itemToUpdate: ListItem?
    
    init(mainContext: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.mainContext = mainContext
        fetchItems()
    }
    
    func addItem(name: String, ongoing: Bool,  priority: Int16, deadline: Date?) {
        let item = ListItem(context: mainContext)
        item.completed = false
        item.dateCreated = date
        item.name = name
        item.ongoing = ongoing
        item.priority = priority
        item.taskDeadline = deadline
        item.uuid = UUID()
        
        setLocalNotification(deadline: deadline, taskName: name)
        saveData()
    }
    
    func completeTask(_ item: ListItem) {
        item.completed.toggle()
        item.completed ? (item.dateCompleted = date) : (item.dateCompleted = nil)
        if item.taskDeadline != nil {
            resetLocalNotifications()
        }
    }
    
    func cleanUpCoreData() {
        let request = NSFetchRequest<ListItem>(entityName: "ListItem")
        
        do {
            let itemsToDelete = try mainContext.fetch(request).filter{ $0.dateCreated ?? Date.now < twoMonthsAgo }
            for item in itemsToDelete {
                if (item.ongoing && item.dateCompleted ?? Date.now < twoMonthsAgo) || !item.ongoing {
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
        mainContext.delete(item)
        resetLocalNotifications()
        saveData()
    }
    
    func fetchItems() {
        let request = NSFetchRequest<ListItem>(entityName: "ListItem")
        
        do {
            let tempItems = try mainContext.fetch(request).filter{
                Calendar.current.numberOfDaysBetween($0.dateCreated ?? Date.distantFuture, and: date) == 0 ||
                (Calendar.current.numberOfDaysBetween($0.dateCreated ?? Date.distantFuture, and: date) > 0 &&
                 $0.ongoing &&
                 Calendar.current.numberOfDaysBetween($0.dateCompleted ?? Date.distantFuture, and: date) <= 0)
            }
            items = tempItems.sorted(by: {$0.dateCreated! < $1.dateCreated!})
        } catch let error {
            print("Error fetching. \(error)")
        }
    }
    
    func resetLocalNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        let request = NSFetchRequest<ListItem>(entityName: "ListItem")
        do {
            let notifcations = try mainContext.fetch(request)
            for notification in notifcations {
                if(!notification.completed) {
                    setLocalNotification(deadline: notification.taskDeadline, taskName: notification.name ?? "Task")
                }
            }
        } catch let error {
            print("Error fetching. \(error)")
        }
    }
    
    func newLoad() {
        chooseDate = false
        initalLoad = true
        fetchItems()
    }
    
    func saveData() {
        do {
            try mainContext.save()
            fetchItems()
        } catch let error {
            print("Error Saving. \(error)")
        }
    }
    
    func updateItem(_ item: ListItem, name: String, ongoing: Bool,  priority: Int16, deadline: Date?) {
        item.completed = false
        item.name = name
        item.ongoing = ongoing
        item.priority = priority
        item.taskDeadline = deadline
        
        resetLocalNotifications()
        saveData()
    }
    
    func setLocalNotification(deadline: Date?, taskName: String) {
        if let deadline = deadline {
            if Calendar.current.date(byAdding: .minute, value: -10, to: deadline)! > Date.now {
                let formatter = DateFormatter()
                formatter.dateFormat = "hh:mm a"
                let hourString = formatter.string(from: deadline)
                
                let content = UNMutableNotificationContent()
                content.title = "\(hourString)"
                content.subtitle = "\(taskName)"
                content.sound =  UNNotificationSound.default
                let earlyUpdate = Calendar.current.date(byAdding: .minute, value: -10, to: deadline)
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: earlyUpdate?.timeIntervalSinceNow ?? deadline.timeIntervalSinceNow, repeats: false)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request)
            }
        }
    }
}
