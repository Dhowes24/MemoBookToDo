//
//  SheetRowView.swift
//  MemoBookToDo
//
//  Created by Derek Howes on 3/27/23.
//

import SwiftUI

struct SheetRowView: View {
    @StateObject private var viewModel: SheetRowViewModel = SheetRowViewModel()
    
    @State private var completed: Bool
    private var date: Date
    @State var delete: Bool = false
    @State private var dragAmount = CGSize.zero
    private var distances: [UInt8]
    @State private var grow: Bool = false
    var item: ListItem?
    let itemName: String
    @Binding var initialLoad: Bool
    @State var multiline: Bool
    var placement: Double = 0
    @GestureState var press = false
    @Binding var updatingTaskBool: Bool
    @Binding var updatingTaskItem: ListItem?
    @Binding var showTaskEditor: Bool
    
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
        
        _completed = State(initialValue: false)
        self.date = date
        self.distances = item?.name?.asciiValues ?? [8,8,8,8]
        self.item = item
        
        if item?.taskDeadline != nil {
            dateFormatter.dateFormat = "hh:mm a"
            let hourString = dateFormatter.string(from: item!.taskDeadline!)
            self.itemName = "\(hourString): \(item?.name ?? "Error")"
        } else {
            self.itemName = item?.name ?? "Error"
        }
        _initialLoad = initialLoad
        
        let nameWidth: CGFloat = itemName.size(withAttributes: [.font: UIFont.systemFont(ofSize: taskNameFontSize)]).width
        if nameWidth > taskWidthAvailable {
            _multiline = State(initialValue: true)
        } else {
            _multiline = State(initialValue: false)
        }
        
        _updatingTaskBool = updatingTaskBool
        _updatingTaskItem = updatingTaskItem
        _showTaskEditor = showTaskEditor
        
        self.placement = placement
        self.completeItem = completeItem
        self.deleteItem = deleteItem
    }
    
    var body: some View {
        
        ZStack {
            HStack(alignment: .center) {
                if let item = item{
                    Group {
                        ZStack(){
                            if multiline{
                                SheetRowSeparator()
                            }
                            Group{
                                HStack(){
                                    BulletPoint(grow: grow, initialLoad: initialLoad)
                                        .offset(x:0, y: multiline ? -20 : 0)
                                    TaskName(grow: grow,
                                             name: itemName,
                                             priorityColor: viewModel.priorityColor(item),
                                             multiline: multiline)
                                    Spacer()
                                }
                                .offset(x: delete ? -UIScreen.mainWidth : 0 , y:0)
                                CrossOutShapeView(completed: completed,
                                                  distances: distances,
                                                  initialLoad: initialLoad,
                                                  placement: placement)
                                .offset(x:0, y: multiline ? -20 : 0)
                                
                                if multiline {
                                    CrossOutShapeView(completed: completed,
                                                      distances: distances,
                                                      initialLoad: initialLoad,
                                                      placement: placement,
                                                      multi: true)
                                    .offset(x:0, y: 20)
                                    .offset(x: delete ? -UIScreen.mainWidth : 0 , y:0)
                                }
                            }
                            .opacity(press ? 0.5 : 1.0)
                            TrashLabel(dragAmount: dragAmount, multiline: multiline)
                        }
                    }
                    .background(colors.paperWhite)
                    .modifier(sheetRowOnAppearViewMod(
                        completed: $completed,
                        grow: $grow,
                        initialLoad: $initialLoad,
                        item: item,
                        placement: placement))
                    
                    .modifier(sheetRowDeleteViewMod(
                        delete: $delete,
                        drag: $dragAmount,
                        item: item,
                        deleteItem: deleteItem))
                    
                    .modifier(sheetRowTapGestureViewMod(
                        completed: $completed,
                        initialLoad: $initialLoad,
                        item: item,
                        completeItem: completeItem))
                    
                    .modifier(sheetRowNameChangeViewMod(
                        itemName: itemName,
                        multiline: $multiline))

                    .modifier(sheetRowTaskEditViewMod(
                        currentItem: item,
                        press: press,
                        updatingTaskBool: $updatingTaskBool,
                        updatingTaskItem: $updatingTaskItem,
                        showTaskEditor: $showTaskEditor))
                }
                
            }
            .frame(maxWidth: .infinity,
                   minHeight: multiline ?  doubleRowHeight : rowHeight,
                   maxHeight: multiline ?  doubleRowHeight : rowHeight)
            .background(colors.paperWhite)
            
            HStack(){
                Color.clear
                    .contentShape(Rectangle())
                    .frame(maxWidth: 50,
                           minHeight: multiline ?  doubleRowHeight : rowHeight,
                           maxHeight: multiline ?  doubleRowHeight : rowHeight)
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
