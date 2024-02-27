//
//  CrossOutShapeView.swift
//  MemoBookToDo
//
//  Created by Derek Howes on 4/6/23.
//

import SwiftUI
import PureSwiftUI

private let gridLayoutGuide = LayoutGuideConfig.grid(columns: 45, rows: 10)
private typealias Curve = (p: CGPoint, cp1: CGPoint, cp2: CGPoint)

struct CrossOutShapeView: View{
    @Environment(\.colorScheme) var colorScheme

    var completed: Bool
    var initialLoad: Bool
    var placement: Double
    var multi: Bool
    var squiggle: Squiggle
    
    init(completed: Bool, distances: [UInt8], initialLoad: Bool, placement: Double, multi: Bool = false) {
        self.completed = completed
        self.initialLoad = initialLoad
        self.placement = placement
        self.multi = multi
        
        var distancesInts: [Int] = []
        for i in (multi ? 0 : distances.count-4)..<(multi ? 4: distances.count) {
            if i >= 0 && i < distances.count{
                distancesInts.append(Int(distances[i] % 8) + 2)
            } else {
                distancesInts.append(8)
            }
        }
        self.squiggle = MemoBookToDo.Squiggle(distances: distancesInts)
    }
    
    var body: some View {
        ZStack {
            squiggle
                .trim(from: 0, to: completed ? 1 : 0)
                .stroke(
                    colorScheme == .dark ? colors.paperWhite : colors.offBlack,
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .frame(height: 25)
        }
    }
}

struct Squiggle: Shape {
    let squiggles: Int = 3
    var distances: [Int]
    let spacing: Int = 10
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let grid = gridLayoutGuide.layout(in: rect)
        var curves = [Curve]()
            
        let point0 = grid[-1,8]
        path.move(point0)
        
        for i in 0...squiggles {
            let distance = distances[i] + (spacing * i)

            let point1 = grid[distance, 2]
            curves.append(Curve(point1,
                               grid[distance, 1],
                                grid[distance, 1]))

            let point2 = grid[distance-1, 7]
            curves.append(Curve(point2,
                                grid[distance-1, 4],
                                grid[distance-2, 7]))
        }

        for curve in curves {
            path.curve(curve.p, cp1: curve.cp1, cp2: curve.cp2)
        }

        let endPoint = grid[46,4]
        path.curve(endPoint, cp1: endPoint, cp2: endPoint)
                
        return path
    }
}


struct CrossOutShapeView_Previews: PreviewProvider {
    static var previews: some View {
        CrossOutShapeView(completed: true, distances: [8,8,8,8], initialLoad: false, placement: 0.0)
            .showLayoutGuides(true)
    }
}
