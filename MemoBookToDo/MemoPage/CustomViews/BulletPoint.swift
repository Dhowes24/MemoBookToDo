//
//  BulletPoint.swift
//  MemoBookToDo
//
//  Created by Derek Howes on 4/8/23.
//

import SwiftUI

struct BulletPoint: View {
    @Environment(\.colorScheme) var colorScheme

    var grow: Bool
    var initialLoad: Bool
    let diameter: CGFloat = 15
    
    var body: some View {
        ZStack{
            Circle()
                .fill(colorScheme == .dark ? colors.paperWhite : colors.offBlack)
                .frame(width: diameter,height: diameter, alignment: .leading)
                .padding(.horizontal, diameter)
                .reverseMask {
                    RoundedRectangle(5)
                        .offset(x:0, y: grow ? -diameter: 0)
                        .rotate(45.degrees)
                }
        }
    }
}

struct BulletPoint_Previews: PreviewProvider {
    static var previews: some View {
        BulletPoint(grow: false, initialLoad: false)
    }
}
