//
//  TextExtensions.swift
//  MemoBookToDo
//
//  Created by Derek Howes on 4/11/23.
//

import Foundation

extension StringProtocol {
    var asciiValues: [UInt8] { compactMap(\.asciiValue) }
}
