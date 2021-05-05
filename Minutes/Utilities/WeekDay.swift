//
//  WeekDay.swift
//  Minutes
//
//  Created by Jonathan Bown on 3/23/21.
//

import Foundation


/*
 Published array of weekdays that monitors if certain days of the week are selected. 
 */
class WeekDays: ObservableObject {
    @Published var weekDays: [WeekDay]

    init(){

            self.weekDays = [
                WeekDay(2, name: "Mon"), WeekDay(3, name: "Tue"), WeekDay(4, name: "Wed"), WeekDay(5, name: "Thu"), WeekDay(6, name: "Fri"), WeekDay(7, name: "Sat"), WeekDay(1, name: "Sun")
            ]
    
        }

    
    func populateSelections(currentDays: [String]){
        if(currentDays.isEmpty){
            for index in 0..<self.weekDays.count {
               
                    self.weekDays[index].reset()
            }
        }
        else {
            for index in 0..<self.weekDays.count {
                if(currentDays.contains(self.weekDays[index].weekDayString)){
                    self.weekDays[index].select()
                }
            }
        }
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
    
    mutating func reset() {
        self.isSelected = false
    }
}






