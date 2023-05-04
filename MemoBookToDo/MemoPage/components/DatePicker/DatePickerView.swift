//
//  DatePicker.swift
//  MemoBookToDo
//
//  Created by Derek Howes on 4/19/23.
//
//
import SwiftUI

struct DatePickerView: View {
    @Binding var date: Date

    var body: some View {
        VStack{
            DatePicker("", selection: $date,
                       in: twoMonthsAgo ... twoMonthsAway,
                       displayedComponents: .date)
                .datePickerStyle(.graphical)
        }
        .frame(width: UIScreen.mainWidth-60)
        .padding()
        .background(
        RoundedRectangle(cornerSize: CGSize(25))
            .fill(.white)
            .shadow(radius: 5)
        )
    }
}

struct DatePickerView_Previews: PreviewProvider {
    static var previews: some View {
        DatePickerView(date: .constant(Date.now))
    }
}
