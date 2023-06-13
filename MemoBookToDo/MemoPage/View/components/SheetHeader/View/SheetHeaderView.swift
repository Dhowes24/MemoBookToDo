//
//  SheetHeaderView.swift
//  MemoBookToDo
//
//  Created by Derek Howes on 3/27/23.
//

import SwiftUI

struct SheetHeaderView: View {
    @StateObject private var viewModel: SheetHeaderViewModel = SheetHeaderViewModel()
    
    @Binding var chooseDate: Bool
    @Binding var date: Date
    @Binding var initialLoad: Bool
    @State private var offset: CGSize = CGSize.zero
    @State private var offsetAnimation: CGFloat = 0
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
                            .foregroundColor(offBlack)
                    }
                    Spacer()
                }
                
                Group {
                    Text(viewModel.todaysName(date: date))
                        .font(.system(size: 36))
                    Text(date, style: .date)
                        .font(.system(size: 14))
                }
                .foregroundColor(offBlack)
                .offset( x:offsetAnimation, y:0)
                .offset( x:offset.width / 4 , y:0)
                
                HStack {
                    Spacer()
                    Button {
                        withAnimation(Animation.easeInOut(duration: 0.3)) {
                            showTaskEditor.toggle()
                            initialLoad = false
                        }
                        
                    } label: {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .padding(.horizontal, 15)
                            .padding(.bottom, 5)
                            .foregroundColor(offBlack)
                    }
                }
            }
        }
        .frame(
            width: UIScreen.main.bounds.width,
            height: 230)
        .padding(.bottom, 10)
        .background(paperWhite)
        .gesture(
            DragGesture().onChanged(
                { gesture in
                    offset = gesture.translation
                }
            )
            .onEnded({ _ in
                if abs(offset.width) > 75 {
                    var dayChange = DateComponents()
                    dayChange.day =  offset.width > 0 ? -1 : 1
                    date = Calendar.current.date(
                        byAdding: dayChange,
                        to: date) ?? date
                    withAnimation(Animation.linear) {
                        offsetAnimation = (offset.width > 0 ? 1 : -1) * UIScreen.mainWidth / 2
                    }
                }
                withAnimation {
                    offsetAnimation = 0
                    offset = .zero
                }
            })
        )
    }
}

struct SheetHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        SheetHeaderView  (chooseDate: .constant(false),
                          date: .constant(Date.now),
                          initialLoad: .constant(true),
                          showTaskEditor: .constant(false))
    }
}
