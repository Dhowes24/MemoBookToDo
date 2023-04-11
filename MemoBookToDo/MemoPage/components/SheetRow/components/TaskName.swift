//
//  TaskName.swift
//  MemoBookToDo
//
//  Created by Derek Howes on 4/8/23.
//

import SwiftUI

struct TaskName: View {
    @Environment(\.colorScheme) var colorScheme
    
    var grow: Bool
    var name: String
    var priorityColor: Color
    var multiline: Bool
    
    var body: some View {
        ZStack {
            HStack(alignment: .bottom){
                Text(name)
                    .foregroundColor(colorScheme == .dark ? paperWhite : offBlack)
                    .font(.system(size: taskNameFontSize))
                    .padding(.horizontal, 10)
                    .lineSpacing(15)
                    .lineLimit(2)
                    .background(
                        VStack(spacing: 15){
                            RoundedRectangle(cornerSize: CGSize(15.0))
                                .fill(priorityColor)
                            
                            if multiline {
                                RoundedRectangle(cornerSize: CGSize(15.0))
                                    .fill(priorityColor)
                            }
                        }
                    )
                    .mask(Rectangle().offset(x: grow ? 0 : -UIScreen.mainWidth))
            }
        }
    }
}

struct TaskName_Previews: PreviewProvider {
    static var previews: some View {
        TaskName(grow: true, name: "Do A Chore", priorityColor: priorityLow, multiline: false)
    }
}
