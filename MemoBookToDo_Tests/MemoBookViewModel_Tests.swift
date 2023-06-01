//
//  MemoBookViewModel_Tests.swift
//  MemoBookToDo_Tests
//
//  Created by Derek Howes on 5/31/23.
//

import XCTest
import CoreData
import Foundation
@testable import MemoBookToDo

class MemoBookViewModel_Tests: XCTestCase {
    
    var testVm: MemoPageViewModel!
    var coreDataStack: CoreDataTestStack!
    
    var taskName = "Task Name"
    var ongoing = false
    var priority = Int16(0)
    
    override func setUpWithError() throws {
        super.setUp()
        coreDataStack = CoreDataTestStack()
        testVm = MemoPageViewModel(mainContext: coreDataStack.mainContext)
        
    }

    override func tearDownWithError() throws {

    }
    
    func pullFullItemData() -> [ListItem] {
        var testItems:[ListItem] = []
        let request = NSFetchRequest<ListItem>(entityName: "ListItem")
        
        do {
            testItems = try coreDataStack.mainContext.fetch(request)
        } catch let error {
            print("Error fetching. \(error)")
        }
        
        return testItems
    }

    //Add Item Tests------------------------------------------------
    func test_addItem() throws {
        // Given
        let deadline = Date.now
        
        // When
        testVm.addItem(name: taskName, ongoing: ongoing, priority: priority, deadline: deadline)
        
        // Then
        let items = testVm.items
        XCTAssertTrue(testVm.items[0].name == taskName)
        XCTAssertTrue(testVm.items[0].ongoing == ongoing)
        XCTAssertTrue(testVm.items[0].priority == priority)
        XCTAssertTrue(testVm.items[0].taskDeadline == deadline)
    }

    //Complete Task Tests ------------------------------------------
    func test_completeTask() throws {
        //Given
        
        //When
        testVm.addItem(name: taskName, ongoing: ongoing, priority: priority, deadline: nil)
        
        //Then
        XCTAssertFalse(testVm.items[0].completed)
        testVm.completeTask(testVm.items[0])
        XCTAssertTrue(testVm.items[0].completed)
        testVm.completeTask(testVm.items[0])
        XCTAssertFalse(testVm.items[0].completed)
    }
    
    func test_completeTask_ongoing_task_over_multiple_days() throws {
        //Given
        var dateComponent = DateComponents()
        dateComponent.day = -4
        let dateCreatedInPast = Calendar.current.date(
            byAdding: dateComponent,
            to: Date.now)
        testVm.date = dateCreatedInPast!
        
        //When
        testVm.addItem(name: taskName, ongoing: true, priority: Int16(0), deadline: nil)
        testVm.date = Date.now
        testVm.completeTask(testVm.items[0])
        
        //Then
        XCTAssertTrue(testVm.items[0].completed)
        print(testVm.items[0])
        XCTAssertTrue( Calendar.current.startOfDay(for: testVm.items[0].dateCompleted!) == Calendar.current.startOfDay(for: Date.now))
        testVm.completeTask(testVm.items[0])
        XCTAssertTrue(testVm.items[0].dateCompleted == nil)
    }
    
    //Clean Up Core Data Tests----------------------------------------
    func test_cleanUpCoreData_remove_none() throws {
        // Given
        var testItems:[ListItem] = []
        
        let dateCreatedToday = Date.now
        
        var dateComponent = DateComponents()
        dateComponent.month = -1
        dateComponent.day = -27
        let dateCreatedWithinPastCutoff = Calendar.current.date(
            byAdding: dateComponent,
            to: Date.now)
        
        dateComponent.month = 1
        dateComponent.day = 20
        let dateCreatedWithinFutureCutoff = Calendar.current.date(
            byAdding: dateComponent,
            to: Date.now)
        
        // When
        testVm.date = dateCreatedToday
        testVm.addItem(name: taskName, ongoing: ongoing, priority: priority, deadline: nil)

        testVm.date = dateCreatedWithinPastCutoff!
        testVm.addItem(name: taskName, ongoing: ongoing, priority: priority, deadline: nil)

        testVm.date = dateCreatedWithinFutureCutoff!
        testVm.addItem(name: taskName, ongoing: ongoing, priority: priority, deadline: nil)
        
        // Then
        testItems = pullFullItemData()
        let dateCreated1 = testItems.filter { $0.dateCreated == dateCreatedToday}
        let dateCreated2 = testItems.filter { $0.dateCreated == dateCreatedWithinPastCutoff}
        let dateCreated3 = testItems.filter { $0.dateCreated == dateCreatedWithinFutureCutoff}
        XCTAssertTrue(dateCreated1.count == 1 && dateCreated2.count == 1 && dateCreated3.count == 1)
        
        testVm.cleanUpCoreData()
        
        testItems = pullFullItemData()
        let dateCreated1AfterClean = testItems.filter { $0.dateCreated == dateCreatedToday}
        let dateCreated2AfterClean = testItems.filter { $0.dateCreated == dateCreatedWithinPastCutoff}
        let dateCreated3AfterClean = testItems.filter { $0.dateCreated == dateCreatedWithinFutureCutoff}
        XCTAssertTrue(dateCreated1AfterClean.count == 1 && dateCreated2AfterClean.count == 1 && dateCreated3AfterClean.count == 1)
    }
    
    func test_cleanUpCoreData_remove_some() throws {
        // Given
        var testItems:[ListItem] = []
        
        let dateCreatedToday = Date.now
        
        var dateComponent = DateComponents()
        dateComponent.month = -2
        dateComponent.day = -1
        let dateCreatedOutsidePastCutoff = Calendar.current.date(
            byAdding: dateComponent,
            to: Date.now)
        
        dateComponent.month = 2
        dateComponent.day = 1
        let dateCreatedOutsideFutureCutoff = Calendar.current.date(
            byAdding: dateComponent,
            to: Date.now)
        
        // When
        testVm.date = dateCreatedToday
        testVm.addItem(name: taskName, ongoing: ongoing, priority: priority, deadline: nil)

        testVm.date = dateCreatedOutsidePastCutoff!
        testVm.addItem(name: taskName, ongoing: ongoing, priority: priority, deadline: nil)

        testVm.date = dateCreatedOutsideFutureCutoff!
        testVm.addItem(name: taskName, ongoing: ongoing, priority: priority, deadline: nil)
        
        // Then
        testItems = pullFullItemData()
        let dateCreated1 = testItems.filter { $0.dateCreated == dateCreatedToday}
        let dateCreated2 = testItems.filter { $0.dateCreated == dateCreatedOutsidePastCutoff}
        let dateCreated3 = testItems.filter { $0.dateCreated == dateCreatedOutsideFutureCutoff}
        XCTAssertTrue(dateCreated1.count == 1 && dateCreated2.count == 1 && dateCreated3.count == 1)
        
        testVm.cleanUpCoreData()
        
        testItems = pullFullItemData()
        let dateCreated1AfterClean = testItems.filter { $0.dateCreated == dateCreatedToday}
        let dateCreated2AfterClean = testItems.filter { $0.dateCreated == dateCreatedOutsidePastCutoff}
        let dateCreated3AfterClean = testItems.filter { $0.dateCreated == dateCreatedOutsideFutureCutoff}
        print(testItems)
        XCTAssertTrue(dateCreated1AfterClean.count == 1 && dateCreated2AfterClean.count == 0 && dateCreated3AfterClean.count == 1)
    }
    
    //Delete Item Tests -----------------------------------------------------
    func test_deleteItem() throws {
        //Given
        let name = "Task Name"
        let ongoing = false
        let priority = Int16(0)
        
        //When
        testVm.addItem(name: taskName, ongoing: ongoing, priority: priority, deadline: nil)
        
        //Then
        XCTAssert(testVm.items.count == 1)
        
        testVm.deleteItem(testVm.items[0])
        
        XCTAssert(testVm.items.count == 0)
    }
    
    //Fetch Items Tests -----------------------------------------------------
    func test_fetchItems() throws {
        //Given
        let name = "Task Name"
        let ongoing = false
        let priority = Int16(0)
        
        let dateCreatedToday = Date.now
        var dateComponent = DateComponents()
        dateComponent.day = 1
        let dateCreatedTomorrow = Calendar.current.date(
            byAdding: dateComponent,
            to: Date.now)

        //When
        testVm.addItem(name: taskName, ongoing: ongoing, priority: priority, deadline: nil)
        testVm.date = dateCreatedTomorrow!
        testVm.addItem(name: taskName, ongoing: ongoing, priority: priority, deadline: nil)
        testVm.date = dateCreatedToday
        
        //Then
        testVm.fetchItems()
        XCTAssert(testVm.items.count == 1)
    }
    
    func test_fetchItems_with_unfinished_Ongoing() throws {
        //Given
        let name = "Task Name"
        let ongoing = false
        let priority = Int16(0)
        var dateComponent = DateComponents()
        dateComponent.day = -1
        let dateCreatedYesterday = Calendar.current.date(
            byAdding: dateComponent,
            to: Date.now)
        
        let dateCreatedToday = Date.now
        dateComponent.day = 1

        //When
        testVm.addItem(name: taskName, ongoing: ongoing, priority: priority, deadline: nil)
        testVm.date = dateCreatedYesterday!
        testVm.addItem(name: taskName, ongoing: true, priority: priority, deadline: nil)
        testVm.date = dateCreatedToday
        
        //Then
        testVm.fetchItems()
        XCTAssert(testVm.items.count == 2)
    }
    
    func test_fetchItems_with_finished_Ongoing() throws {
        //Given
        var dateComponent = DateComponents()
        dateComponent.day = -1
        let dateCreatedYesterday = Calendar.current.date(
            byAdding: dateComponent,
            to: Date.now)
        
        let dateCreatedToday = Date.now

        //When
        testVm.addItem(name: taskName, ongoing: ongoing, priority: priority, deadline: nil)

        testVm.date = dateCreatedYesterday!
        testVm.addItem(name: taskName, ongoing: true, priority: priority, deadline: nil)
        testVm.completeTask(testVm.items[0])
        
        testVm.addItem(name: taskName, ongoing: true, priority: priority, deadline: nil)
        testVm.date = dateCreatedToday
        testVm.completeTask(testVm.items[1])
        
        //Then
        testVm.fetchItems()
        XCTAssert(testVm.items.count == 2)
    }
    
    //Delete Item Tests -----------------------------------------------------
    func test_deleteItems() throws {
        //Given
        
        //When
        testVm.addItem(name: taskName, ongoing: ongoing, priority: priority, deadline: nil )

        //Then
        XCTAssertTrue(testVm.items.count == 1)
        testVm.deleteItem(testVm.items[0])
        XCTAssertTrue(testVm.items.count == 0)
    }
    
    //Fetch Items Tests --------------------------------------------------
    func test_fetchItems_no_items_that_day() throws {
        //Given
        var dateComponent = DateComponents()
        dateComponent.day = -1
        let yesterday = Calendar.current.date(
            byAdding: dateComponent,
            to: Date.now)
        testVm.date = yesterday!
        testVm.addItem(name: taskName, ongoing: ongoing, priority: priority, deadline: nil)

        //When
        testVm.date = Date.now
        testVm.fetchItems()
        
        //Then
        XCTAssertTrue(testVm.items.count == 0)
    }
    
    func test_fetchItems_items_that_day() throws {
        //Given
        testVm.addItem(name: taskName, ongoing: ongoing, priority: priority, deadline: nil)
        testVm.addItem(name: taskName, ongoing: ongoing, priority: priority, deadline: nil)

        //When
        testVm.fetchItems()
        
        //Then
        XCTAssertTrue(testVm.items.count == 2)
    }
    
    func test_fetchItems_ongoing_from_past() throws {
        //Given
        var dateComponent = DateComponents()
        dateComponent.day = -1
        let yesterday = Calendar.current.date(
            byAdding: dateComponent,
            to: Date.now)
        testVm.date = yesterday!
        testVm.addItem(name: taskName, ongoing: true, priority: priority, deadline: nil)

        //When
        testVm.date = Date.now
        testVm.addItem(name: taskName, ongoing: ongoing, priority: priority, deadline: nil)
        testVm.fetchItems()
        
        //Then
        XCTAssertTrue(testVm.items.count == 2)
    }
    
    
    //Reset Local Notifications Tests -----------------------------------------------------
    func test_resetLocalNotifications_without_notifications_to_reset() throws {
        //Given
        let center = UNUserNotificationCenter.current()
        
        //When
        testVm.addItem(name: taskName, ongoing: ongoing, priority: priority, deadline: nil)
        
        //Then
        testVm.resetLocalNotifications()
        center.getPendingNotificationRequests(completionHandler: { requests in
            XCTAssertTrue(requests.count == 0)
        })
    }
    
    func test_resetLocalNotifications_removing_some_notifications() throws {
        //Given
        let center = UNUserNotificationCenter.current()
        var dateComponent = DateComponents()
        dateComponent.day = 1
        let deadlineTomorrow = Calendar.current.date(
            byAdding: dateComponent,
            to: Date.now)
        //When
        testVm.addItem(name: taskName, ongoing: ongoing, priority: priority, deadline: deadlineTomorrow )
        testVm.addItem(name: taskName, ongoing: ongoing, priority: priority, deadline: deadlineTomorrow )
        
        //Then
        testVm.resetLocalNotifications()
        center.getPendingNotificationRequests(completionHandler: { requests in
            XCTAssertTrue(requests.count == 2)
        })
        
        testVm.completeTask(testVm.items[0])
        center.getPendingNotificationRequests(completionHandler: { requests in
            XCTAssertTrue(requests.count == 1)
        })
    }
    
    
    //New Load Tests -----------------------------------------------------
    func test_newLoad() throws {
        //Given
            testVm.addItem(name: taskName, ongoing: ongoing, priority: priority, deadline: nil )

        //When
            testVm.newLoad()
        
        //Then
        XCTAssertFalse(testVm.chooseDate)
        XCTAssertTrue(testVm.initalLoad)
        XCTAssertTrue(testVm.items.count == 1)
    }
    
    //Update Items Tests -----------------------------------------------------
    func test_updateItems() throws {
        //Given
            testVm.addItem(name: taskName, ongoing: ongoing, priority: priority, deadline: nil )

        //When
        let item = testVm.items[0]
        XCTAssert(item.name == taskName && item.ongoing == ongoing && item.priority == priority)
        
        let updatedName = "Updated Name"
        let updatedOngoing = true
        let updatedPriority = Int16(2)
        let updatedDeadline = Calendar.current.startOfDay(for: Date.now)
        testVm.updateItem(item, name: updatedName, ongoing: updatedOngoing, priority: updatedPriority, deadline: updatedDeadline)
        let updatedItem = testVm.items[0]
        
        //Then
        XCTAssert(item.name == updatedName && item.ongoing == updatedOngoing && item.priority == updatedPriority && item.taskDeadline == updatedDeadline)

    }
    
    //setLocalNotification Tests -----------------------------------------------------
    func test_setLocalNotification() throws {
        //Given
        var dateComponent = DateComponents()
        dateComponent.day = 1
        let thisTimeTomorrow = Calendar.current.date(
            byAdding: dateComponent,
            to: Date.now)
        
        let center = UNUserNotificationCenter.current()

        //When
        testVm.setLocalNotification(deadline: thisTimeTomorrow, taskName: "Valid Notification")
        
        //Then
        center.getPendingNotificationRequests(completionHandler: { requests in
            XCTAssertTrue(requests.count == 1)
        })
    }
    
    func test_setLocalNotification_within_10_mins() throws {
        //Given
        let rightNow = Date.now
        
        let center = UNUserNotificationCenter.current()

        //When
        testVm.setLocalNotification(deadline: rightNow, taskName: "invalid Notification")
        
        //Then
        center.getPendingNotificationRequests(completionHandler: { requests in
            XCTAssertTrue(requests.count == 0)
        })
        
    }
}
