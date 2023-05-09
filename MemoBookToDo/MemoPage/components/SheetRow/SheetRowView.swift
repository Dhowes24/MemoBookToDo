//
//  SheetRowView.swift
//  MemoBookToDo
//
//  Created by Derek Howes on 3/27/23.
//

import SwiftUI

struct SheetRowView: View {
    @Environment(\.colorScheme) var colorScheme    
    @State private var completed: Bool
    private var date: Date
    @State var delete: Bool = false
    @State private var dragAmount = CGSize.zero
    private var distances: [UInt8]
    @State private var grow: Bool = false
    var item: ListItem?
    let itemName: String
    @Binding var initalLoad: Bool
    @State var multiline: Bool
    var number: Double = 0
    @GestureState private var pressing = false
    @Binding var updatingTaskBool: Bool
    @Binding var updatingTaskItem: ListItem?
    @Binding var showTaskEditor: Bool

    var saveItem: (() -> Void)?
    var deleteItem: ((ListItem) -> Void)?
    
    init(date: Date = Date.now,
         item: ListItem? = nil,
         initalLoad: Binding<Bool>,
         number: Double = 0,
         saveItem: ( () -> Void)? = nil,
         deleteItem: ( (ListItem) -> Void)? = nil,
         updatingTaskBool: Binding<Bool>,
         updatingTaskItem: Binding<ListItem?>,
         showTaskEditor: Binding<Bool>) {
        
        _completed = State(initialValue: false)
        self.date = date
        self.distances = item?.name?.asciiValues ?? [8,8,8,8]
        self.item = item
        
        if item?.taskDeadline != nil {
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            let hourString = formatter.string(from: item!.taskDeadline!)
            self.itemName = "\(hourString): \(item?.name ?? "Error")"
        } else {
            self.itemName = item?.name ?? "Error"
        }
        _initalLoad = initalLoad
        
        let nameWidth: CGFloat = itemName.size(withAttributes: [.font: UIFont.systemFont(ofSize: taskNameFontSize)]).width
        if nameWidth > taskWidthAvaliable {
            _multiline = State(initialValue: true)
        } else {
            _multiline = State(initialValue: false)
        }
        
        _updatingTaskBool = updatingTaskBool
        _updatingTaskItem = updatingTaskItem
        _showTaskEditor = showTaskEditor
        
        self.number = number
        self.saveItem = saveItem
        self.deleteItem = deleteItem
    }
    
    var body: some View {
            HStack(alignment: .center) {
                if let item = item{
                    Group {
                        ZStack(){
                            if multiline{
                                SheetRowSeperator()
                            }
                            Group{
                                HStack(){
                                    BulletPoint(grow: grow, initalLoad: initalLoad, number: number)
                                        .offset(x:0, y: multiline ? -20 : 0)
                                    TaskName(grow: grow,
                                             name: itemName,
                                             priorityColor: priorityColor(item),
                                             multiline: multiline)
                                    Spacer()
                                }
                                .offset(x: delete ? -UIScreen.mainWidth : 0 , y:0)
                                CrossoutShapeView(completed: completed,
                                                  distances: distances,
                                                  initalLoad: initalLoad,
                                                  number: number)
                                .offset(x:0, y: multiline ? -20 : 0)
                                
                                if multiline {
                                    CrossoutShapeView(completed: completed,
                                                      distances: distances,
                                                      initalLoad: initalLoad,
                                                      number: number,
                                                      multi: true)
                                    .offset(x:0, y: 20)
                                    .offset(x: delete ? -UIScreen.mainWidth : 0 , y:0)
                                }
                            }
                            TrashLabel(dragAmount: dragAmount, multiline: multiline)
                        }
                    }
                    .background(paperWhite)
                    .opacity(pressing ? 0.5 : 1)
                    .simultaneousGesture(
                        LongPressGesture(minimumDuration: 0.5)
                            .updating($pressing, body: { val, state, transaction in
                                state = val
                            })
                            .onEnded(
                                { _ in
                                    withAnimation {
                                        updatingTaskBool = true
                                        updatingTaskItem = item
                                        showTaskEditor = true
                                    }
                                }
                            )
                    )
                    .modifier(SheetRowViewModifier(
                        completed: $completed,
                        date: date,
                        delete: $delete,
                        drag: $dragAmount,
                        grow: $grow,
                        initalLoad: $initalLoad,
                        item: item,
                        itemName: itemName,
                        multiline: $multiline,
                        number: number,
                        saveItem: saveItem,
                        deleteItem: deleteItem))
                }
            }
            .frame(maxWidth: .infinity,
                   minHeight: multiline ?  doubleRowHeight : rowHeight,
                   maxHeight: multiline ?  doubleRowHeight : rowHeight )
            .background(paperWhite)
    }
    
    func priorityColor(_ item: ListItem) -> Color{
        switch item.priority{
        case 1:
            return priorityLow
        case 2:
            return priorityMedium
        case 3:
            return priorityHigh
        default:
            return paperWhite.opacity(0)
        }
    }
    
}

struct SheetRowViewModifier: ViewModifier {
    @Binding var completed: Bool
    var date: Date
    @Binding var delete: Bool
    @Binding var drag : CGSize
    @Binding var grow: Bool
    @Binding var initalLoad: Bool
    var item: ListItem
    var itemName: String
    @Binding var multiline: Bool
    var number: Double
    
    var saveItem: (() -> Void)?
    var deleteItem: ((ListItem) -> Void)?
    
    func body(content: Content) -> some View {
        content
            .onAppear(perform: {
                withAnimation(Animation.easeInOut(duration: animationDuration).delay(initalLoad ? number * initialLoadDelay : 0)) {
                    grow = true
                    completed = item.completed
                }
            })
            .gesture(
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
                        initalLoad = false
                        withAnimation(Animation.easeInOut(duration: animationDuration)) {
                            item.completed.toggle()
                            completed.toggle()
                            if item.onGoing {
                                item.dateCompleted = completed ? date : nil
                            }
                            saveItem!()
                        }
                    }
            )
            .onChange(of: itemName) { newName in
                let nameWidth: CGFloat = newName.size(withAttributes: [.font: UIFont.systemFont(ofSize: taskNameFontSize)]).width
                if nameWidth > taskWidthAvaliable {
                    multiline = true
                } else {
                    multiline = false
                }
            }
    }
}

struct SheetRowView_Previews: PreviewProvider {
    static var previews: some View {
        let previewDataController = PreviewDataController()
        let item = previewDataController.savePreviewData()
        
        return SheetRowView(item: item, initalLoad: .constant(false), updatingTaskBool: .constant(false), updatingTaskItem: .constant(nil), showTaskEditor: .constant(false))
            .environment(
                \.managedObjectContext,
                 previewDataController.viewContext
            )
    }
}
