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
    var initalLoad: Bool
    var number: Double
    let diameter: CGFloat = 15
    
    var body: some View {
        ZStack{
            Circle()
                .fill(colorScheme == .dark ? paperWhite : offBlack)
                .frame(width: diameter,height: diameter, alignment: .leading)
                .padding(.horizontal, diameter)
                .reverseMask {
                    RoundedRectangle(5)
                        .offset(x:0, y: grow ? -diameter: 0)
                        .rotate(45.degrees)
                        .transaction { transaction in
                            transaction.animation = Animation.linear(duration: 0.25).delay(
                                initalLoad ? number * 0.25 : 0)
                        }
                }
        }
    }
}

struct BulletPoint_Previews: PreviewProvider {
    static var previews: some View {
        BulletPoint(grow: false, initalLoad: false, number: 0.0)
    }
}
