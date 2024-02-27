//
//  SheetRowViewModel.swift
//  MemoBookToDo
//
//  Created by Derek Howes on 6/13/23.
//

import Foundation
import SwiftUI

class SheetRowViewModel: ObservableObject {
    @Published var completed: Bool
    var date: Date
    @Published var delete: Bool = false
    @Published var dragAmount = CGSize.zero
    var distances: [UInt8]
    @Published var grow: Bool = false
    var item: ListItem?
    let itemName: String
    @Binding var initialLoad: Bool
    @Published var multiline: Bool
    var placement: Double = 0
    @Binding var updatingTaskBool: Bool
    @Binding var updatingTaskItem: ListItem?
    @Binding var showTaskEditor: Bool

    init(completed: Bool,
         date: Date,
         item: ListItem?,
         initialLoad: Binding<Bool>,
         updatingTaskBool: Binding<Bool>,
         updatingTaskItem: Binding<ListItem?>,
         showTaskEditor: Binding<Bool>
    ) {
        self.completed = completed
        self.date = date
        self.distances = item?.name?.asciiValues ?? [8,8,8,8]
        self.item = item
        
        if let deadline = item?.taskDeadline {
            dateFormatter.dateFormat = "hh:mm a"
            let hourString = dateFormatter.string(from: deadline)
            self.itemName = "\(hourString): \(item?.name ?? "Error")"
        } else {
            self.itemName = item?.name ?? "Error"
        }
        
        _initialLoad = initialLoad
        _multiline = SheetRowViewModel.calculateMultiline(string: itemName)
        
                _updatingTaskBool = updatingTaskBool
                _updatingTaskItem = updatingTaskItem
                _showTaskEditor = showTaskEditor
    }
    
 
    func priorityColor(_ item: ListItem) -> Color{
        switch item.priority{
        case 1:
            return colors.priorityLow
        case 2:
            return colors.priorityMedium
        case 3:
            return colors.priorityHigh
        default:
            return colors.paperWhite.opacity(0)
        }
    }
    
    private static func calculateMultiline(string: String) -> Published<Bool> {
        let nameWidth: CGFloat = string.size(withAttributes: [.font: UIFont.systemFont(ofSize: taskNameFontSize)]).width

        return Published(initialValue: nameWidth > taskWidthAvailable)
    }
}
