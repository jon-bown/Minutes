//
//  GoalEditForm.swift
//  Minutes
//
//  Created by Jonathan Bown on 9/28/20.
//

import SwiftUI

struct GoalEditForm: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @Binding var isPresented: Bool
    
    var goal: Goal
    
    @State private var goalName: String = ""
    @State private var goalColor: String = ""
    @State private var goalDailyTime: Int?
    @State private var goalFrequency: String = ""
    @State private var goalDay: String = ""
    @State private var goalCol: Color = Color(.sRGB, red: 0.98, green: 0.9, blue: 0.2)
    @State private var startDate: Date = Date()
    
    
    let freq = ["Daily", "Weekly", "Monthly"]
    let dOTW = ["M", "T", "W", "TH", "F", "Sa", "Su"]
    
    var body: some View {
        NavigationView{
            VStack{
   
            Form{
                Section(header: Text("New Goal").padding(5).lineLimit(nil)){
                    TextField("Name", text: self.$goalName)
                    ColorPicker("Color Theme", selection: self.$goalCol, supportsOpacity: false)
                    TextField("Minutes", value: $goalDailyTime, formatter: NumberFormatter())
                        .keyboardType(UIKeyboardType.decimalPad)
                    Picker("Frequency", selection: self.$goalFrequency) {
                        ForEach(self.freq, id: \.self) { freq in
                            Text(freq)
                    }
                }
                    if(self.goalFrequency == "Weekly"){
                        Picker("Day", selection: self.$goalDay) {
                        ForEach(self.dOTW, id: \.self) { day in
                            Text(day)
                        }
                    }
                    }
                    DatePicker("Start On:", selection: self.$startDate, displayedComponents: .date)
                }
            }.padding()
                Button(action: {
                    self.saveGoal()
                }) {
                    HStack {
                        Spacer()
                        Text("Save")
                            .font(.headline)
                            .foregroundColor(Color.white)
                        Spacer()
                    }
                }
                .padding(.vertical, 10.0)
                .background(Color.red)
                .cornerRadius(4.0)
                .padding(.horizontal, 50)
                Spacer()
            }.navigationBarTitle("Edit", displayMode: .inline).navigationBarItems(trailing: Button(action: {
                self.isPresented = false
            }){
                Image(systemName: "x.circle").font(Font.system(size: 30, weight: .regular))
            })
            //add navigation elements including x button
        }.onAppear(){
            self.goalName = goal.name!
            self.goalCol = Color(goal.color!)
            
            
        }
    }
    
    private func saveContext() {
      do {
        try managedObjectContext.save()
      } catch {
        print("Error saving managed object context: \(error)")
      }
        managedObjectContext.refresh(self.goal, mergeChanges: true)
    }
    
    private func saveGoal(){

        // 2
        print(goalName)
        self.goal.name = goalName

        // 3
        saveContext()
        
        self.isPresented = false
    }
}

//struct GoalEditForm_Previews: PreviewProvider {
//    static var previews: some View {
//        GoalEditForm(isPresented: .constant(true))
//    }
//}
