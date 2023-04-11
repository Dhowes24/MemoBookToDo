//
//  SheetHeaderView.swift
//  MemoBookToDo
//
//  Created by Derek Howes on 3/27/23.
//

import SwiftUI

struct SheetHeaderView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var deleteItems: () -> Void
    @Binding var initalLoad: Bool
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
                        deleteItems()
                    } label: {
                        Image(systemName: "calendar")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .padding(.horizontal, 15)
                            .foregroundColor(colorScheme == .dark ? paperWhite : offBlack)
                    }
                    Spacer()
                }
                
                Text("Today")
                    .font(.system(size: 36))
                Text("dd/mm/yyyy")
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
                    }
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.25)
        .padding(0)
    }
}

struct SheetHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        SheetHeaderView  (deleteItems: {
            //
        }, initalLoad: .constant(true),
                          
                          showTaskEditor: .constant(false))
    }
}
