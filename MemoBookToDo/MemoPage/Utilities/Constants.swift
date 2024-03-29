//
//  Constants.swift
//  MemoBookToDo
//
//  Created by Derek Howes on 4/11/23.
//

import Foundation
import SwiftUI

//Colors
//_______________________________________________________

enum colors {
    static let blueSeparator: Color = Color.init(hex: 0x6296C6)
    static let paperWhite: Color = Color.init(hex: 0xF5F5F5)
    static let priorityLow: Color = Color.init(hex: 0xB3F395)
    static let priorityMedium: Color = Color.init(hex: 0xF4DD88)
    static let priorityHigh: Color = Color.init(hex: 0xf48f88)
    static let offBlack: Color = Color.init(hex: 0x363636)
}

let opacityVal = 0.4

//Animations
//_______________________________________________________
let animationDuration = 0.5
let initialLoadDelay = 0.3

//Dimensions
//_______________________________________________________
let capsuleHorizontalPadding: CGFloat = 10
let doubleRowHeight: CGFloat = 82
let rowHeight: CGFloat = 40
let taskNameFontSize: CGFloat = 20
let taskWidthAvailable: CGFloat = UIScreen.mainWidth - 80

//Dates
//_______________________________________________________
var twoMonthsAgo: Date = (Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date.distantPast)
var twoMonthsAway: Date = (Calendar.current.date(byAdding: .month, value: 2, to: Date()) ?? Date.distantFuture)
var dateFormatter = DateFormatter()
