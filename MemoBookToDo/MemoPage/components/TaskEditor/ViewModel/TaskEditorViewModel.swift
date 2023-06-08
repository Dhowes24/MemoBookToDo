//
//  TaskEditorViewModel.swift
//  MemoBookToDo
//
//  Created by Derek Howes on 6/8/23.
//

import Foundation
import SwiftUI

class TaskEditorViewModel: ObservableObject {
    
    var addItem: (String, Bool, Int16, Date?) -> Void
    var date: Date
    @Published var ongoing: Bool = false
    let priorities = ["None", "Low", "Medium", "High"]
    let regularText: CGFloat = 14
    @Published var selection = "None"
    @Binding var showEditor: Bool
    @Published var taskName: String = ""
    @Published var taskDeadline: Date
    @Published var taskDeadlineBool: Bool = false
    @FocusState var textIsFocused: Bool
    @Binding var updating: Bool
    @Binding var itemToUpdate: ListItem?
    var updateItem: (ListItem, String, Bool, Int16, Date?) -> Void
    
    init(
        addItem: @escaping (String, Bool, Int16, Date?) -> Void,
        date: Date,
        showEditor: Binding<Bool>,
        updating: Binding<Bool>,
        itemToUpdate: Binding<ListItem?>,
        updateItem: @escaping (ListItem, String, Bool, Int16, Date?) -> Void
    )
    {
        self.addItem = addItem
        self.date = date
        self._showEditor = showEditor
        self.taskDeadline = Calendar.current.startOfDay(for: date)
        self._updating = updating
        self._itemToUpdate = itemToUpdate
        self.updateItem = updateItem
    }
    
    
    
}
