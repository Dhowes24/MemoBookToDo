//
//  ShapeExtensions.swift
//  MemoBookToDo
//
//  Created by Derek Howes on 4/6/23.
//

import SwiftUI

private let demoStrokeStyle = StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)

private extension Shape {
    func demoStyle() -> some View {
        stroke(Color.white, style:demoStrokeStyle)
    }
}
