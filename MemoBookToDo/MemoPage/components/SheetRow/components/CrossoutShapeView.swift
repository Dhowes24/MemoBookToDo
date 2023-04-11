//
//  CrossoutShapeView.swift
//  MemoBookToDo
//
//  Created by Derek Howes on 4/6/23.
//

import SwiftUI
import PureSwiftUI

private let gridLayoutGuide = LayoutGuideConfig.grid(columns: 45, rows: 10)
private typealias Curve = (p: CGPoint, cp1: CGPoint, cp2: CGPoint)

struct CrossoutShapeView: View{
    @Environment(\.colorScheme) var colorScheme

    var completed: Bool
    var initalLoad: Bool
    var number: Double
    var multi: Bool
    var squiggle: squiggle
    
    init(completed: Bool, distances: [UInt8], initalLoad: Bool, number: Double, multi: Bool = false) {
        self.completed = completed
        self.initalLoad = initalLoad
        self.number = number
        self.multi = multi
        
        var distancesInts: [Int] = []
        for i in (multi ? 0 : distances.count-4)..<(multi ? 4: distances.count) {
            if i >= 0 && i < distances.count{
                distancesInts.append(Int(distances[i] % 8) + 2)
            } else {
                distancesInts.append(8)
            }
        }
        self.squiggle = MemoBookToDo.squiggle(distances: distancesInts)
    }
    
    var body: some View {
        ZStack {
            squiggle
                .trim(from: 0, to: completed ? 1 : 0)
                .stroke(
                    colorScheme == .dark ? paperWhite : offBlack,
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .frame(height: 25)
                .transaction { transaction in
                    transaction.animation = Animation.easeInOut(duration: animationDuration).delay(
                        ((initalLoad ? number * initialLoadDelay + initialLoadDelay : 0) + (multi ? initialLoadDelay : 0))
                    )
                }
        }
    }
}

struct squiggle: Shape {
    let squiggles: Int = 3
    var distances: [Int]
    let spacing: Int = 10
    
    func path(in rect: CGRect) -> Path {

        var path = Path()
        let g = gridLayoutGuide.layout(in: rect)
        var curves = [Curve]()
            
        let p1 = g[-1,8]
        path.move(p1)
        
        for i in 0...squiggles {
            let distance = distances[i] + (spacing * i)

            let point1 = g[distance, 2]
            curves.append(Curve(point1,
                               g[distance, 1],
                               g[distance, 1]))

            let point2 = g[distance-1, 7]
            curves.append(Curve(point2,
                               g[distance-1, 4],
                               g[distance-2, 7]))
        }

        for curve in curves {
            path.curve(curve.p, cp1: curve.cp1, cp2: curve.cp2)
        }
        
//        let p2 = g[6,2]
//        path.curve(p2, cp1: g[6, 1], cp2: g[6, 1])
//
//        let p3 = g[5, 7]
//        path.curve(p3, cp1: g[5, 4], cp2: g[4, 7])
//
//        let p4 = g[16,3]
//        path.curve(p4, cp1: g[16,2], cp2: g[16,2])
//
//        let p5 = g[15,8]
//        path.curve(p5, cp1: g[15,5], cp2: g[14,8])
//
//        let p6 = g[24,2]
//        path.curve(p6, cp1: g[24, 1], cp2: g[24, 1])
//
//        let p7 = g[24,7]
//        path.curve(p7, cp1: g[24,4], cp2: g[23,7])
//
//        let p8 = g[34,3]
//        path.curve(p8, cp1: g[34,2], cp2: g[34,2])
//
//        let p9 = g[34,8]
//        path.curve(p9, cp1: g[34,5], cp2: g[33,8])

        let endPoint = g[46,4]
        path.curve(endPoint, cp1: endPoint, cp2: endPoint)
                
        return path
    }
}


struct CrossoutShapeView_Previews: PreviewProvider {
    static var previews: some View {
        CrossoutShapeView(completed: true, distances: [8,8,8,8], initalLoad: false, number: 0.0)
            .showLayoutGuides(true)
    }
}
