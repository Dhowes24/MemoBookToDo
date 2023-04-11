//
//  SheetRowView.swift
//  MemoBookToDo
//
//  Created by Derek Howes on 3/27/23.
//

import SwiftUI

struct SheetRowView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var completed: Bool = false
    @State var delete: Bool = false
    var distances: [UInt8]
    @State private var grow: Bool = false
    var item: ListItem?
    @Binding var initalLoad: Bool
    let multiline: Bool
    var number: Double = 0

    var saveItem: (() -> Void)?
    var deleteItem: ((ListItem) -> Void)?
    
    init(item: ListItem? = nil, initalLoad: Binding<Bool>, number: Double = 0, saveItem: ( () -> Void)? = nil, deleteItem: ( (ListItem) -> Void)? = nil) {
        
        self.distances = item?.name?.asciiValues ?? [8,8,8,8]
        self.item = item
        self._initalLoad = initalLoad
        
        let nameWidth: CGFloat = item?.name?.size(withAttributes: [.font: UIFont.systemFont(ofSize: taskNameFontSize)]).width ?? 0
        if nameWidth > taskWidthAvaliable {
            self.multiline = true
        } else {
            self.multiline = false
        }
        
        self.number = number
        self.saveItem = saveItem
        self.deleteItem = deleteItem
        
    }
    
    var body: some View {
            HStack(alignment: .center) {
                if let item = item{
                    Group {
                        ZStack(){
                            HStack(){
                                BulletPoint(grow: grow, initalLoad: initalLoad, number: number)
                                    .offset(x:0, y: multiline ? -20 : 0)
                                TaskName(grow: grow, name: item.name ?? "ERROR", priorityColor: priorityColor(item), multiline: multiline)
                                Spacer()
                            }
                            CrossoutShapeView(completed: completed, distances: distances, initalLoad: initalLoad, number: number)
                                .offset(x:0, y: multiline ? -20 : 0)
                            
                            if multiline {
                                CrossoutShapeView(completed: completed, distances: distances, initalLoad: initalLoad, number: number, multi: true)
                                    .offset(x:0, y: 20)
                            }
                        }
                        .opacity(delete ? 0 : 1)
                    }
                    .contextMenu{
                        Button("Delete Item", action: {
                            if let deleteItem = deleteItem {
                                deleteItem(item)
                            }
                        })
                        Button("Edit Item", action: {})
                    }
                    .onTapGesture(perform: {
                        initalLoad = false
                        withAnimation(Animation.easeInOut(duration: animationDuration)) {
                            item.completed.toggle()
                            completed.toggle()
                            saveItem!()
                        }
                    })
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: animationDuration).delay((initalLoad ? number * initialLoadDelay : 0))) {
                            grow = true
                            completed = item.completed
                        }
                    }
                }
        }
        .frame(maxWidth: .infinity,
               minHeight: rowHeight,
               maxHeight: multiline ?  doubleRowHeight : rowHeight )
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
            return paperWhite
        }
    }
}

struct SheetRowView_Previews: PreviewProvider {
    static var previews: some View {
        let previewDataController = PreviewDataController()

        let item = previewDataController.savePreviewData()
        
        return SheetRowView(item: item, initalLoad: .constant(false))
            .environment(
                \.managedObjectContext,
                 previewDataController.viewContext
            )
    }
}
