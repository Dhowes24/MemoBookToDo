//
//  SheetRowViewModifier.swift
//  MemoBookToDo
//
//  Created by Derek Howes on 2/26/24.
//

import Foundation
import SwiftUI

struct SheetRowViewModifier: ViewModifier {
    @Binding var completed: Bool
    var date: Date
    @Binding var delete: Bool
    @Binding var drag : CGSize
    @Binding var grow: Bool
    @Binding var initialLoad: Bool
    var item: ListItem
    var itemName: String
    @Binding var multiline: Bool
    var placement: Double
    
    var completeItem: ((ListItem) -> Void)?
    var deleteItem: ((ListItem) -> Void)?
    
    func body(content: Content) -> some View {
        content
            .onAppear(perform: {
                withAnimation(Animation.easeInOut(duration: animationDuration).delay(initialLoad ? placement * initialLoadDelay : 0)) {
                    grow = true
                    completed = item.completed
                }
            })
            .simultaneousGesture(
                DragGesture()
                    .onChanged({
                        if $0.translation.width < 0 {
                            drag = $0.translation
                        }
                    })
                    .onEnded({ _ in
                        withAnimation(Animation.linear(duration: 0.3)) {
                            if drag.width < -60 {
                                delete.toggle()
                                if let deleteItem = deleteItem {
                                    deleteItem(item)
                                }
                            }
                            drag = .zero
                        }
                    })
            )
            .simultaneousGesture(
                TapGesture()
                    .onEnded { _ in
                        initialLoad = false
                        withAnimation(Animation.easeInOut(duration: animationDuration)) {
                            if let completeItem = completeItem {
                                completeItem(item)
                            }
                            completed.toggle()
                        }
                    }
            )
            .onChange(of: itemName) { newName in
                let nameWidth: CGFloat = newName.size(withAttributes: [.font: UIFont.systemFont(ofSize: taskNameFontSize)]).width
                if nameWidth > taskWidthAvailable {
                    multiline = true
                } else {
                    multiline = false
                }
            }
    }
}
