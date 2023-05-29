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
let blueSeperator: Color = Color.init(hex: 0x6296C6)
let paperWhite: Color = Color.init(hex: 0xF5F5F5)
let priorityLow: Color = Color.init(hex: 0xB3F395)
let priorityMedium: Color = Color.init(hex: 0xF4DD88)
let priorityHigh: Color = Color.init(hex: 0xf48f88)
let offBlack: Color = Color.init(hex: 0x363636)
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
let taskWidthAvaliable: CGFloat = UIScreen.mainWidth - 80

//Dates
//_______________________________________________________
var twoMonthsAgo: Date = (Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date.distantPast)
var twoMonthsAway: Date = (Calendar.current.date(byAdding: .month, value: 2, to: Date()) ?? Date.distantFuture)
