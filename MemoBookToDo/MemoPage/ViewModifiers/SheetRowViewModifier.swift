//
//  SheetRowViewModifier.swift
//  MemoBookToDo
//
//  Created by Derek Howes on 2/26/24.
//

import Foundation
import SwiftUI

struct sheetRowOnAppearViewMod: ViewModifier {
    @Binding var completed: Bool
    @Binding var grow: Bool
    @Binding var initialLoad: Bool
    var item: ListItem
    var placement: Double
    
    func body(content: Content) -> some View {
        content
            .onAppear(perform: {
                withAnimation(Animation.easeInOut(duration: animationDuration).delay(initialLoad ? placement * initialLoadDelay : 0)) {
                    grow = true
                    completed = item.completed
                }
            })
    }
}


struct sheetRowDeleteViewMod: ViewModifier {
    @Binding var delete: Bool
    @Binding var drag : CGSize
    var item: ListItem
    
    var deleteItem: ((ListItem) -> Void)?
    
    func body(content: Content) -> some View {
        content
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
    }
}


struct sheetRowTapGestureViewMod: ViewModifier {
    @Binding var completed: Bool
    @Binding var initialLoad: Bool
    var item: ListItem
    
    var completeItem: ((ListItem) -> Void)?
    
    func body(content: Content) -> some View {
        content
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
    }
}


struct sheetRowNameChangeViewMod: ViewModifier {
    var itemName: String
    @Binding var multiline: Bool
    
    func body(content: Content) -> some View {
        content
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


struct sheetRowTaskEditViewMod: ViewModifier {
    var currentItem: ListItem
    @GestureState var press: Bool
    @Binding var updatingTaskBool: Bool
    @Binding var updatingTaskItem: ListItem?
    @Binding var showTaskEditor: Bool
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture (
                LongPressGesture(minimumDuration: 0.6)
                    .updating($press) { currentState, gestureState, transaction in
                        gestureState = currentState
                    }
                    .onEnded{ finished in
                        withAnimation {
                            updatingTaskBool = true
                            updatingTaskItem = currentItem
                            showTaskEditor = true
                        }
                    }
            )
    }
}
