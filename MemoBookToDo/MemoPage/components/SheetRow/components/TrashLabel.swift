//
//  TrashLabel.swift
//  MemoBookToDo
//
//  Created by Derek Howes on 4/24/23.
//

import SwiftUI

struct TrashLabel: View {
    var dragAmount: CGSize
    var multiline: Bool
    
    var body: some View {
        Image(sfSymbol: "trash")
            .frame(width: 40, height: multiline ?  doubleRowHeight : rowHeight)
            .foregroundColor(paperWhite)
            .background(
                Rectangle()
                    .fill(.red)
                    )
            .offset(x: abs(dragAmount.width) > 60 ?
                    UIScreen.mainWidth/2 - 20
                    : UIScreen.mainWidth/2 + 20 - (40 * (abs(dragAmount.width) / 60))
            )
    }
}

struct TrashLabel_Previews: PreviewProvider {
    static var previews: some View {
        TrashLabel(dragAmount: CGSize.zero, multiline: true)
    }
}
