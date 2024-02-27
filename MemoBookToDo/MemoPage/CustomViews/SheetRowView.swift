//
//  SheetRowView.swift
//  MemoBookToDo
//
//  Created by Derek Howes on 3/27/23.
//

import SwiftUI

struct SheetRowView: View {
    @StateObject private var viewModel: SheetRowViewModel
    @GestureState var press = false

    var completeItem: ((ListItem) -> Void)?
    var deleteItem: ((ListItem) -> Void)?
    
    init(date: Date = Date.now,
         item: ListItem? = nil,
         initialLoad: Binding<Bool>,
         placement: Double = 0,
         completeItem: ((ListItem) -> Void)? = nil,
         deleteItem: ((ListItem) -> Void)? = nil,
         updatingTaskBool: Binding<Bool>,
         updatingTaskItem: Binding<ListItem?>,
         showTaskEditor: Binding<Bool>) {
        
        _viewModel = StateObject(wrappedValue: SheetRowViewModel(
            completed: false,
            date: date,
            item: item ?? nil,
            initialLoad: initialLoad,
            updatingTaskBool: updatingTaskBool,
            updatingTaskItem: updatingTaskItem,
            showTaskEditor: showTaskEditor
        ))

        self.completeItem = completeItem
        self.deleteItem = deleteItem
    }
    
    var body: some View {
        ZStack {
            HStack(alignment: .center) {
                if let item = viewModel.item{
                    Group {
                        ZStack(){
                            if viewModel.multiline{
                                SheetRowSeparator()
                            }
                            Group{
                                HStack(){
                                    BulletPoint(grow: viewModel.grow, initialLoad: viewModel.initialLoad)
                                        .offset(x:0, y: viewModel.multiline ? -20 : 0)
                                    TaskName(grow: viewModel.grow,
                                             name: viewModel.itemName,
                                             priorityColor: viewModel.priorityColor(item),
                                             multiline: viewModel.multiline)
                                    Spacer()
                                }
                                .offset(x: viewModel.delete ? -UIScreen.mainWidth : 0 , y:0)
                                CrossOutShapeView(completed: viewModel.completed,
                                                  distances: viewModel.distances,
                                                  initialLoad: viewModel.initialLoad,
                                                  placement: viewModel.placement)
                                .offset(x:0, y: viewModel.multiline ? -20 : 0)
                                
                                if viewModel.multiline {
                                    CrossOutShapeView(completed: viewModel.completed,
                                                      distances: viewModel.distances,
                                                      initialLoad: viewModel.initialLoad,
                                                      placement: viewModel.placement,
                                                      multi: true)
                                    .offset(x:0, y: 20)
                                    .offset(x: viewModel.delete ? -UIScreen.mainWidth : 0 , y:0)
                                }
                            }
                            .opacity(press ? 0.5 : 1.0)
                            TrashLabel(dragAmount: viewModel.dragAmount, multiline: viewModel.multiline)
                        }
                    }
                    .background(colors.paperWhite)
                    .modifier(SheetRowViewModifier(
                        completed: $viewModel.completed,
                        date: viewModel.date,
                        delete: $viewModel.delete,
                        drag: $viewModel.dragAmount,
                        grow: $viewModel.grow,
                        initialLoad: $viewModel.initialLoad,
                        item: item,
                        itemName: viewModel.itemName,
                        multiline: $viewModel.multiline,
                        placement: viewModel.placement,
                        completeItem: completeItem,
                        deleteItem: deleteItem))
                    .simultaneousGesture (
                        LongPressGesture(minimumDuration: 0.6)
                            .updating($press) { currentState, gestureState, transaction in
                                gestureState = currentState
                            }
                            .onEnded{ finished in
                                withAnimation {
                                    viewModel.updatingTaskBool = true
                                    viewModel.updatingTaskItem = viewModel.item
                                    viewModel.showTaskEditor = true
                                }
                            }
                    )
                }
                
            }
            .frame(maxWidth: .infinity,
                   minHeight: viewModel.multiline ?  doubleRowHeight : rowHeight,
                   maxHeight: viewModel.multiline ?  doubleRowHeight : rowHeight)
            .background(colors.paperWhite)
            
            HStack(){
                Color.clear
                    .contentShape(Rectangle())
                    .frame(maxWidth: 50,
                           minHeight: viewModel.multiline ?  doubleRowHeight : rowHeight,
                           maxHeight: viewModel.multiline ?  doubleRowHeight : rowHeight)
                Spacer()
            }
        }
    }
}


struct SheetRowView_Previews: PreviewProvider {
    static var previews: some View {
        let previewDataController = PreviewDataController()
        let item = previewDataController.savePreviewData()
        
        return SheetRowView(item: item, initialLoad: .constant(false), updatingTaskBool: .constant(false), updatingTaskItem: .constant(nil), showTaskEditor: .constant(false))
            .environment(
                \.managedObjectContext,
                 previewDataController.viewContext
            )
    }
}
