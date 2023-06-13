//
//  SheetHeaderViewModel.swift
//  MemoBookToDo
//
//  Created by Derek Howes on 6/12/23.
//

import Foundation
import SwiftUI

class SheetHeaderViewModel: ObservableObject {
    
    func todaysName(date: Date) -> String{
        let f = DateFormatter()
        let diff = Calendar.current.numberOfDaysBetween(Date.now, and: date)

        switch diff {
        case -1:
            return "Yesterday"
        case 0:
            return "Today"
        case 1:
            return "Tomorrow"
        default:
            return f.weekdaySymbols[Calendar.current.component(.weekday, from: date)-1]
        }
    }
}
