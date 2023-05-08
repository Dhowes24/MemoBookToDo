//
//  TaskEditorView.swift
//  MemoBookToDo
//
//  Created by Derek Howes on 4/8/23.
//

import SwiftUI

struct TaskEditorView: View {
    var addItem: (String, Bool, Int16, Date?) -> Void
    @FocusState var textIsFocused: Bool
    @State private var ongoing: Bool = false
    let priorities = ["None", "Low", "Medium", "High"]
    let regularText: CGFloat = 14
    @State private var selection = "None"
    @Binding var showEditor: Bool
    @State var taskName: String = ""
    @State var taskDeadline: Date = Calendar.current.startOfDay(for: Date.now)
    @State var taskDeadlingBool: Bool = false

    var body: some View {
        ScrollView {
            Text("Add Task")
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
                self.addItem(taskName, ongoing, Int16(priorities.firstIndex(of: selection) ?? 0), deadline)
                if let deadline = deadline {
                    if deadline > Calendar.current.date(byAdding: .minute, value: -10, to: Date.now)! {
                        scheduleNotification(deadline)
                    }
                }
                withAnimation{
                    showEditor.toggle()
                }
            } label: {
                Text("Save Task")
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
        .frame(width: UIScreen.mainWidth-60)
        .padding()
        .background(
        RoundedRectangle(cornerSize: CGSize(25))
            .fill(.white)
            .shadow(radius: 5)
        )
        .padding()
        .onChange(of: showEditor) { _ in
            taskName = ""
            taskDeadline = Calendar.current.startOfDay(for: Date.now)
            taskDeadlingBool = false
            ongoing = false
            selection = "None"
            textIsFocused = showEditor
        }
    }
    
    func scheduleNotification(_ deadline: Date){
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        let hourString = formatter.string(from: deadline)
        
        let content = UNMutableNotificationContent()
        content.title = "\(hourString)"
        content.subtitle = "\(taskName)"
        content.sound =  UNNotificationSound.default
        let earlyUpdate = Calendar.current.date(byAdding: .minute, value: -10, to: deadline)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: earlyUpdate?.timeIntervalSinceNow ?? deadline.timeIntervalSinceNow, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

struct TaskEditorView_Previews: PreviewProvider {
    static var previews: some View {
        TaskEditorView(addItem: { _,_,_,_ in
            print("Nothing")
        }, showEditor: .constant(true))
    }
}
