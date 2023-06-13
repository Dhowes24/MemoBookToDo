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
    @Published var initialLoad: Bool = true
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
        if Calendar.current.numberOfDaysBetween(date, and: Date.now) != 0 {
            var organizationCounter = 0
            var tempDateCreated: Date
            var tempItems = items
            var forward: Bool = true
            
            if Calendar.current.numberOfDaysBetween(Date.now, and: date) > 0 {
                tempDateCreated = Calendar.current.startOfDay(for: date)
            } else {
                tempDateCreated = Calendar.current.endOfDay(for: date)
                tempItems.reverse()
                forward = false
            }
            
            for i in tempItems {
                if i.dateCreated == tempDateCreated {
                    organizationCounter += 1
                    tempDateCreated = Calendar.current.date(byAdding: .second, value: forward ? organizationCounter : -organizationCounter, to: tempDateCreated)!
                }
            }
            
            item.dateCreated = tempDateCreated
        } else {
            item.dateCreated = date
        }
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
            
            items = tempItems.sorted(by: {
                if $0.dateCreated! ==  $1.dateCreated! {
                    return $0.id < $1.id
                } else {
                    return $0.dateCreated! < $1.dateCreated!
                }
            })

        } catch let error {
            print("Error fetching. \(error)")
        }
    }
    
    func resetLocalNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        let request = NSFetchRequest<ListItem>(entityName: "ListItem")
        do {
            let notifications = try mainContext.fetch(request)
            for notification in notifications {
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
        initialLoad = true
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
                dateFormatter.dateFormat = "hh:mm a"
                let hourString = dateFormatter.string(from: deadline)
                
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
