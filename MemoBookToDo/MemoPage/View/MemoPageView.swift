//
//  ContentView.swift
//  MemoBookToDo
//
//  Created by Derek Howes on 3/24/23.
//
import SwiftUI

struct MemoPageView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var orientation = UIDeviceOrientation.unknown
    @StateObject private var vm = MemoPageViewModel()
    
    init() {
        UIScrollView.appearance().bounces = false
    }
    
    var body: some View {
        GeometryReader{ geo in
            let numOfRows = Int((geo.size.height * 0.75) / rowHeight)

            VStack(alignment: .center, spacing: 0) {
                ScrollView(Axis.Set.vertical) {
                    SheetHeaderView(deleteItems: {vm.resetCoreData()}, initalLoad: $vm.initalLoad, showTaskEditor: $vm.showTaskEditor)
                    
                    ZStack(alignment: .topLeading){
                        VStack(spacing: 0){
                            ForEach(0..<numOfRows, id: \.self) { item in
                                SheetRowSeperator()

                                SheetRowView(initalLoad: .constant(false))
                            }
                            SheetRowSeperator()
                        }
                        
                        VStack(spacing: 0){
                            ForEach(vm.items, id: \.self) { item in
                                    SheetRowSeperator()
                                    
                                    SheetRowView(
                                        item: item,
                                        initalLoad: $vm.initalLoad,
                                        number: 0,
                                        saveItem: {vm.saveData()},
                                        deleteItem: {_ in vm.deleteItem(item)})
                            }
                        }
                    }
                    .offset(y:-10)
                }
            }
            .backgroundColor(colorScheme == .dark ? offBlack : paperWhite)
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
                ZStack(alignment: .center){
                    Color.black.opacity(vm.showTaskEditor ? opacityVal : 0)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                vm.showTaskEditor.toggle()
                            }
                        }
                    TaskEditorView(addItem: vm.addItem, showEditor: $vm.showTaskEditor)
                        .scale(vm.showTaskEditor ? 1 : 0)
                }
                .opacity(vm.showTaskEditor ? 1 : 0)
        }
    }
}



struct MemoPageView_Previews: PreviewProvider {
    static var previews: some View {
        MemoPageView()
    }
}
