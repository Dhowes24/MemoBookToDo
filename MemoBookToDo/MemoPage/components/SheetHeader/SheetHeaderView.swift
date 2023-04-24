//
//  SheetHeaderView.swift
//  MemoBookToDo
//
//  Created by Derek Howes on 3/27/23.
//

import SwiftUI

struct SheetHeaderView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var chooseDate: Bool
    @Binding var date: Date
    var deleteItems: () -> Void
    @Binding var initalLoad: Bool
    @State private var orientation = UIDeviceOrientation.unknown
    @Binding var showTaskEditor: Bool
    
    var body: some View {
        GeometryReader { geo in
            let numOfHoles = Int(geo.size.width / 46)
            
            VStack(spacing: 0){
                HStack {
                    ForEach(0..<numOfHoles, id: \.self) { _ in
                        SheetHeaderPunchHoleView()
                    }
                }
                .padding(.bottom, 15)
                
                HStack {
                    Button {
                        withAnimation {
                            chooseDate = true
                        }
                    } label: {
                        Image(systemName: "calendar")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .padding(.horizontal, 15)
                            .foregroundColor(colorScheme == .dark ? paperWhite : offBlack)
                    }
                    Spacer()
                }
                
                Text(todaysName())
                    .font(.system(size: 36))
                Text(date, style: .date)
                    .font(.system(size: 14))
                
                HStack {
                    Spacer()
                    Button {
                        withAnimation(Animation.easeInOut(duration: 0.3)) {
                            showTaskEditor.toggle()
                            initalLoad = false
                        }
                        
                    } label: {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .padding(.horizontal, 15)
                            .padding(.bottom, 5)
                            .foregroundColor(colorScheme == .dark ? paperWhite : offBlack)
                            .offset(x: orientation.isLandscape ? -60 : 0)
                    }
                }
            }
        }
        .frame(
            width: UIScreen.main.bounds.width,
            height: orientation.isLandscape ? 220 :
            UIScreen.main.bounds.height * 0.25)
        .padding(0)
        .offset(x: orientation.isLandscape ? -20 : 0)
        .onRotate { newOrientation in
            orientation = newOrientation
        }
    }
    
    func todaysName() -> String{
        let f = DateFormatter()
        let diff = Calendar.current.numberOfDaysBetween(Date.now, and: date)

        switch diff {
        case -1:
            return "Yesterday"
        case 0:
            return "Today"
        case 1:
            return "Tomorrow"
        default:
//            let weekDay = Calendar.current.component(.weekday, from: date)
//            return
            return f.weekdaySymbols[Calendar.current.component(.weekday, from: date)-1]
        }
    }
}

struct SheetHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        SheetHeaderView  (chooseDate: .constant(false), date: .constant(Date.now),
            deleteItems: {
            //
        }, initalLoad: .constant(true),
                          
                          showTaskEditor: .constant(false))
    }
}
