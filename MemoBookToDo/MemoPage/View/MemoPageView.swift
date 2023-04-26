//
//  ContentView.swift
//  MemoBookToDo
//
//  Created by Derek Howes on 3/24/23.
//
import SwiftUI
import UserNotifications

struct MemoPageView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var vm = MemoPageViewModel()
    
    init() {
        UIScrollView.appearance().bounces = false
    }
    
    var body: some View {
        GeometryReader{ geo in
            let numOfRows = Int((geo.size.height * 0.75) / rowHeight)
            
            VStack(alignment: .center, spacing: 0) {
                ScrollView(Axis.Set.vertical) {
                    SheetHeaderView(
                        chooseDate: $vm.chooseDate,
                        date: $vm.date,
                        deleteItems: {vm.resetCoreData()},
                        initalLoad: $vm.initalLoad,
                        showTaskEditor: $vm.showTaskEditor)
                    
                    ZStack(alignment: .topLeading){
                        VStack(spacing: 0){
                            ForEach(0..<numOfRows, id: \.self) { item in
                                SheetRowSeperator()
                                
                                SheetRowView(initalLoad: .constant(false))
                            }
                            SheetRowSeperator()
                        }
                        
                        VStack(spacing: 0){
                            ForEach(Array(vm.items), id: \.self) { item in
                                SheetRowSeperator()
                                
                                SheetRowView(
                                    date: vm.date,
                                    item: item,
                                    initalLoad: $vm.initalLoad,
                                    number: Double(vm.items.firstIndex(of: item) ?? 0),
                                    saveItem: {vm.saveData()},
                                    deleteItem: {_ in vm.deleteItem(item) })
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
                Color.black.opacity(vm.showTaskEditor || vm.chooseDate ? opacityVal : 0)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            vm.showTaskEditor = false
                            vm.chooseDate = false
                        }
                    }
                DatePickerView(date: $vm.date)
                    .offset(x: vm.chooseDate ? 0: -UIScreen.mainWidth)
                TaskEditorView(addItem: vm.addItem, showEditor: $vm.showTaskEditor)
                    .offset(x: vm.showTaskEditor ? 0: UIScreen.mainWidth)
            }
            .opacity(vm.showTaskEditor || vm.chooseDate  ? 1 : 0)
        }
        .onChange(of: vm.date) { _ in
            withAnimation {
                vm.newLoad()
            }
        }
    }
}

struct MemoPageView_Previews: PreviewProvider {
    static var previews: some View {
        MemoPageView()
    }
}
