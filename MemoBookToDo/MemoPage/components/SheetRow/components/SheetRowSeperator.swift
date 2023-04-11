//
//  SheetRowSeperator.swift
//  MemoBookToDo
//
//  Created by Derek Howes on 4/8/23.
//

import SwiftUI

struct SheetRowSeperator: View {
    var body: some View {
        Rectangle()
            .fill(blueSeperator)
            .frame(maxWidth: .infinity, maxHeight: 2)
    }
}

struct SheetRowSeperator_Previews: PreviewProvider {
    static var previews: some View {
        SheetRowSeperator()
    }
}
