//
//  SheetRowViewModel.swift
//  MemoBookToDo
//
//  Created by Derek Howes on 4/10/23.
//

import Foundation
import SwiftUI

extension SheetRowView {
    @MainActor class SheetRowViewModel: ObservableObject {
        
        var item: ListItem?
        var number: Double = 0
        
        @Published var delete: Bool = false
        @Binding var initalLoad: Bool
        @Published var grow: Bool = false
        @Published var completed: Bool = false
        
        var saveItem: (() -> Void)?
        var deleteItem: ((ListItem) -> Void)?
        
        let multiline: Bool
        
        init(item: ListItem? = nil, number: Double = 0, initalLoad: Binding<Bool>, saveItem: ( () -> Void)? = nil, deleteItem: ( (ListItem) -> Void)? = nil) {
            self.item = item
            self.number = number
            self._initalLoad = initalLoad
            self.saveItem = saveItem
            self.deleteItem = deleteItem
            
            if item?.name?.count ?? 0 >  25 {
                self.multiline = true
            } else {
                self.multiline = false
            }
        }
    }
}
