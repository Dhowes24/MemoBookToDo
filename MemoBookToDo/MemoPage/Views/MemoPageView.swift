//
//  ContentView.swift
//  MemoBookToDo
//
//  Created by Derek Howes on 3/24/23.
//
import SwiftUI
import UserNotifications

struct MemoPageView: View {
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var viewModel = MemoPageViewModel()
    
    init() {
        UIScrollView.appearance().bounces = false
    }
    
    var body: some View {
        GeometryReader{ screen in
            let numOfRows = Int((screen.size.height - 230) / rowHeight)
            
            VStack(alignment: .center, spacing: 0) {
                ScrollView(Axis.Set.vertical) {
                    SheetHeaderView(
                        chooseDate: $viewModel.chooseDate,
                        date: $viewModel.date,
                        initialLoad: $viewModel.initialLoad,
                        showTaskEditor: $viewModel.showTaskEditor)
                    
                    ZStack(alignment: .topLeading){
                        VStack(spacing: 0){
                            ForEach(0..<numOfRows, id: \.self) { item in
                                SheetRowSeparator()
                                
                                SheetRowView(
                                    initialLoad: .constant(false),
                                    updatingTaskBool: .constant(false),
                                    updatingTaskItem: .constant(nil),
                                    showTaskEditor: .constant(false)
                                )
                            }
                            SheetRowSeparator()
                        }
                        
                        VStack(spacing: 0){
                            ForEach(Array(viewModel.items), id: \.self) { item in
                                SheetRowSeparator()
                                
                                SheetRowView(
                                    date: viewModel.date,
                                    item: item,
                                    initialLoad: $viewModel.initialLoad,
                                    placement: Double(viewModel.items.firstIndex(of: item) ?? 0),
                                    completeItem: {_ in viewModel.completeTask(item) },
                                    deleteItem: {_ in viewModel.deleteItem(item) },
                                    updatingTaskBool: $viewModel.updatingTaskBool,
                                    updatingTaskItem: $viewModel.itemToUpdate,
                                    showTaskEditor: $viewModel.showTaskEditor)
                            }
                        }
                    }
                }
                .padding(.bottom, 30)
            }
            .backgroundColor(paperWhite)
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            ZStack(alignment: .center){
                Color.black.opacity(viewModel.showTaskEditor || viewModel.chooseDate ? opacityVal : 0)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            viewModel.showTaskEditor = false
                            viewModel.chooseDate = false
                        }
                    }
                DatePickerView(date: $viewModel.date)
                    .offset(x: viewModel.chooseDate ? 0: -UIScreen.mainWidth)
                TaskEditorView(
                    addItem: viewModel.addItem,
                    date: viewModel.date,
                    showEditor: $viewModel.showTaskEditor,
                    updating: $viewModel.updatingTaskBool,
                    itemToUpdate: $viewModel.itemToUpdate,
                    updateItem: viewModel.updateItem)
                .offset(x: viewModel.showTaskEditor ? 0: UIScreen.mainWidth)
            }
            .opacity(viewModel.showTaskEditor || viewModel.chooseDate  ? 1 : 0)
        }
        .onChange(of: scenePhase) { newPhase in
                viewModel.date = Date.now
        }
        .onChange(of: viewModel.date) { _ in
            withAnimation {
                viewModel.newLoad()
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
            viewModel.cleanUpCoreData()
        }
    }
}

struct MemoPageView_Previews: PreviewProvider {
    static var previews: some View {
        MemoPageView()
    }
}
