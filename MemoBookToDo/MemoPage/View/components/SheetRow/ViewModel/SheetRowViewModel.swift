//
//  SheetRowViewModel.swift
//  MemoBookToDo
//
//  Created by Derek Howes on 6/13/23.
//

import Foundation
import SwiftUI

class SheetRowViewModel: ObservableObject {
 
    func priorityColor(_ item: ListItem) -> Color{
        switch item.priority{
        case 1:
            return priorityLow
        case 2:
            return priorityMedium
        case 3:
            return priorityHigh
        default:
            return paperWhite.opacity(0)
        }
    }
}
