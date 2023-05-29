//
//  ContentView.swift
//  MemoBookToDo
//
//  Created by Derek Howes on 3/24/23.
//
import SwiftUI
import UserNotifications

struct MemoPageView: View {
    @StateObject private var vm = MemoPageViewModel()
    
    init() {
        UIScrollView.appearance().bounces = false
    }
    
    var body: some View {
        GeometryReader{ geo in
            let numOfRows = Int((geo.size.height - 230) / rowHeight)
            
            VStack(alignment: .center, spacing: 0) {
                ScrollView(Axis.Set.vertical) {
                    SheetHeaderView(
                        chooseDate: $vm.chooseDate,
                        date: $vm.date,
                        initalLoad: $vm.initalLoad,
                        showTaskEditor: $vm.showTaskEditor)
                    
                    ZStack(alignment: .topLeading){
                        VStack(spacing: 0){
                            ForEach(0..<numOfRows, id: \.self) { item in
                                SheetRowSeperator()

                                SheetRowView(
                                    initalLoad: .constant(false),
                                    updatingTaskBool: .constant(false),
                                    updatingTaskItem: .constant(nil),
                                    showTaskEditor: .constant(false))

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
                                    deleteItem: {_ in vm.deleteItem(item) },
                                    updatingTaskBool: $vm.updatingTaskBool,
                                    updatingTaskItem: $vm.itemToUpdate,
                                    showTaskEditor: $vm.showTaskEditor)
                            }
                        }
                    }
                }
            }
            .backgroundColor(paperWhite)
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
                TaskEditorView(
                    addItem: vm.addItem,
                    date: vm.date,
                    showEditor: $vm.showTaskEditor,
                    updating: $vm.updatingTaskBool,
                    itemToUpdate: $vm.itemToUpdate,
                    updateItem: vm.updateItem)
                    .offset(x: vm.showTaskEditor ? 0: UIScreen.mainWidth)
            }
            .opacity(vm.showTaskEditor || vm.chooseDate  ? 1 : 0)
        }
        .onChange(of: vm.date) { _ in
            withAnimation {
                vm.newLoad()
            }
        }
        .onAppear {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
//
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
            vm.cleanUpCoreData()
        }
    }
}

struct MemoPageView_Previews: PreviewProvider {
    static var previews: some View {
        MemoPageView()
    }
}
