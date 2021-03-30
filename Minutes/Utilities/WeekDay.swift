//
//  WeekDay.swift
//  Minutes
//
//  Created by Jonathan Bown on 3/23/21.
//

import Foundation


class WeekDays: ObservableObject {
    @Published var weekDays: [WeekDay]

    init(){
        self.weekDays = [
            WeekDay(2, name: "Mon"), WeekDay(3, name: "Tue"), WeekDay(4, name: "Wed"), WeekDay(5, name: "Thu"), WeekDay(6, name: "Fri"), WeekDay(7, name: "Sat"), WeekDay(1, name: "Sun")
        ]
    }
    
    func selectDay(index: Int){
        self.weekDays[index].select()
    }
}


struct WeekDay: Identifiable {
    var id: Int
    var weekDayString: String
    var isSelected: Bool = false
    
    init(_ id: Int, name: String){
        self.id = id
        self.weekDayString = name
    }
    
    mutating func select() {
        self.isSelected = !self.isSelected
    }
}






