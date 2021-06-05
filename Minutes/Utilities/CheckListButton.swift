//
//  CheckListButton.swift
//  Minutes
//
//  Created by Jonathan Bown on 3/9/21.
//

import SwiftUI

struct CheckListButton: View {
    var dateKey: Date
    @Binding var listOfSessions: [Date]
    @State var isChecked: Bool = false
    var body: some View {
        Button(action: {
            if(self.isChecked){
                self.listOfSessions.remove(at: self.listOfSessions.firstIndex(of: dateKey)!)
            }
            else {
                self.listOfSessions.append(dateKey)
            }
            self.isChecked.toggle()
            
        }){
            if(self.isChecked){
                Image(systemName: "checkmark.circle.fill").font(.system(size: 20)).foregroundColor(Constants.checkMarkColor)
            }
            else {
                Image(systemName: "circlebadge").font(.system(size: 20))
            }
            
        }
    }
}
