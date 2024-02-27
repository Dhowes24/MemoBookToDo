//
//  SheetRowSeparator.swift
//  MemoBookToDo
//
//  Created by Derek Howes on 4/8/23.
//

import SwiftUI

struct SheetRowSeparator: View {
    var body: some View {
        Rectangle()
            .fill(colors.blueSeparator)
            .frame(maxWidth: .infinity, maxHeight: 2)
    }
}

struct SheetRowSeparator_Previews: PreviewProvider {
    static var previews: some View {
        SheetRowSeparator()
    }
}
