//
//  HolePunch.swift
//  MemoBookToDo
//
//  Created by Derek Howes on 2/26/24.
//

import SwiftUI
import PureSwiftUIDesign

struct BinderRing: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack{
            ZStack {
                Circle()
                    .fill(colorScheme == .dark ? .black : offBlack)
                    .frame(width: 30, height: 30, alignment: .leading)
                    .padding(.horizontal, 4)
                
                    Ring()
                        .fill(
                            LinearGradient(gradient: Gradient(colors: [.gray, .gray, .white, .gray]), startPoint: .top, endPoint: .bottom)
                        )
                        .frame(width: 25, height: 40)
                        .offset(x:-7, y:-25)
            }
        }
        .frame(height: 65)
    }
}

private let gridLayoutGuide = LayoutGuideConfig.grid(columns: 20, rows: 20)

struct Ring: Shape {
    func path(in rect: CGRect) -> Path {
        
        var path = Path()
        
        let g = gridLayoutGuide.layout(in: rect)
        
        let p1 = g[0,0]
        path.move(p1)
        
        let p2 = g[12,18]
        path.curve(p2, cp1: g[12,13], cp2: g[12,19])
        
        let p3 = g[18,18]
        path.curve(p3, cp1: g[16,23], cp2: g[19,19])
        
        let p4 = g[6,0]
        path.curve(p4, cp1: g[10,3], cp2: p4)
        
        let p5 = g[0,0]
        path.curve(p5, cp1: g[2,-2], cp2: g[0,-2])
                
        return path
    }
}

#Preview {
    BinderRing()
}
