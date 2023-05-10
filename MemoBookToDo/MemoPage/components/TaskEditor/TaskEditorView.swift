//
//  TaskEditorView.swift
//  MemoBookToDo
//
//  Created by Derek Howes on 4/8/23.
//

import SwiftUI

struct TaskEditorView: View {
    var addItem: (String, Bool, Int16, Date?) -> Void
    @State var ongoing: Bool = false
    let priorities = ["None", "Low", "Medium", "High"]
    let regularText: CGFloat = 14
    @State var selection = "None"
    @Binding var showEditor: Bool
    @State var taskName: String = ""
    @State var taskDeadline: Date = Calendar.current.startOfDay(for: Date.now)
    @State var taskDeadlingBool: Bool = false
    @FocusState var textIsFocused: Bool
    @Binding var updating: Bool
    @Binding var itemToUpdate: ListItem?
    var updateItem: (ListItem, String, Bool, Int16, Date?) -> Void
    
    var body: some View {
        ScrollView {
            Text(updating ? "Update Task" : "Add Task")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black)
            
            TextField("Enter Task Name...", text: $taskName, axis: .vertical)
                .frame(height: 60, alignment: .topLeading)
                .font(.system(size:regularText))
                .padding()
                .backgroundColor(paperWhite)
                .cornerRadius(5)
                .padding(10)
                .focused($textIsFocused)
            
            HStack {
                Text("Priority:")
                    .font(.system(size: regularText))
                Picker("",selection: $selection) {
                    ForEach(priorities, id: \.self) {
                        Text($0)
                    }
                }.pickerStyle(.segmented)
            }
            .padding(10)
            
            Toggle(isOn: $taskDeadlingBool) {
                Text("Task Deadline: ")
                    .font(.system(size: regularText))
            }
            .padding(10)
            
            if taskDeadlingBool {
                DatePicker("", selection: $taskDeadline, displayedComponents: .hourAndMinute)
                    .padding(10)
            }
            
            Toggle(isOn: $ongoing) {
                Text("Ongoing until completed: ")
                    .font(.system(size: regularText))
            }
            .padding(10)
            
            Button {
                let deadline = taskDeadlingBool ? taskDeadline : nil
                
                if updating {
                    if let itemToUpdate = itemToUpdate {
                        self.updateItem(itemToUpdate, taskName, ongoing, Int16(priorities.firstIndex(of: selection) ?? 0), deadline)
                    }
                } else {
                    self.addItem(taskName, ongoing, Int16(priorities.firstIndex(of: selection) ?? 0), deadline)
                }
                
                withAnimation{
                    updating = false
                    showEditor.toggle()
                }
            } label: {
                Text(updating ? "Update Task" : "Save Task")
                    .font(.system(size: regularText, weight: .semibold))
                    .padding(.vertical, 5)
                    .padding(.horizontal, capsuleHorizontalPadding)
                    .background(
                    RoundedRectangle(10)
                        .fill(paperWhite)
                        .shadow(radius: 2, x: 0, y:3)
                    )
                    .padding(10)
            }
            .buttonStyle(.plain)
            .disabled(taskName.isEmpty)

        }
        .frame(minWidth: UIScreen.mainWidth-60, maxHeight: UIScreen.halfMainHeight)
        .padding()
        .background(
        RoundedRectangle(cornerSize: CGSize(25))
            .fill(.white)
            .shadow(radius: 5)
        )
        .padding()
        .onChange(of: showEditor) { _ in
            if showEditor && updating {
                taskName = itemToUpdate?.name ?? "No Name"
                taskDeadline = itemToUpdate?.taskDeadline ?? Calendar.current.startOfDay(for: Date.now)
                taskDeadlingBool = itemToUpdate?.taskDeadline != nil
                ongoing = itemToUpdate?.onGoing ?? false
                selection = priorities[Int(itemToUpdate?.priority ?? 0)]
                
            } else {
                taskName = ""
                taskDeadline = Calendar.current.startOfDay(for: Date.now)
                taskDeadlingBool = false
                ongoing = false
                selection = "None"
                textIsFocused = showEditor
                itemToUpdate = nil
                updating = false
            }
        }
    }
}

struct TaskEditorView_Previews: PreviewProvider {
    static var previews: some View {
        TaskEditorView(addItem: { _,_,_,_ in
            print("Nothing")
        }, showEditor: .constant(true), updating: .constant(false), itemToUpdate: .constant(nil)) { _, _, _, _, _ in
            print("Nothing Again")
        }
    }
}
