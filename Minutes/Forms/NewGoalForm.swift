//
//  NewGoalForm.swift
//  Daily Minutes
//
//  Created by Jonathan Bown on 8/13/20.
//

import SwiftUI

struct NewGoalForm: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @Binding var isPresented: Bool
    
    @State private var goalName: String = ""
    @State private var goalColor: String = ""
    @State private var goalDailyTime: Int = 0
    @State private var goalFrequency: String = ""
    @State private var goalDay: String = ""
    @State private var goalCol: Color = Color(.sRGB, red: 0.98, green: 0.9, blue: 0.2)
    @State private var startDate: Date = Date()
    
    
    let freq = ["Daily", "Weekly", "Monthly"]
    let dOTW = ["M", "T", "W", "TH", "F", "Sa", "Su"]
    
    var body: some View {
        NavigationView{
            VStack{
                //TODO: Add close button
            Form{
                //Section(header: Text("New Goal").padding(5).lineLimit(nil)){
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
                //}
            }.padding(5)
                Button(action: {
                    self.addGoal()
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
            }.navigationBarTitle("New Goal", displayMode: .inline).navigationBarItems(trailing: Button(action: {
                self.isPresented = false
            }){
                Image(systemName: "x.circle").font(Font.system(size: 30, weight: .regular))
            })
            //add navigation elements including x button
        }
    }
    
    private func saveContext() {
      do {
        try managedObjectContext.save()
      } catch {
        print("Error saving managed object context: \(error)")
      }
    }
    
    private func addGoal(){
        let newGoal = Goal(context: managedObjectContext)

        // 2
        print(goalName)
        print(self.goalDailyTime)
        newGoal.name = goalName
        newGoal.color = UIColor(goalCol)
        newGoal.cumTime = 0.0
        newGoal.dayTime = 0.0
        newGoal.goalTime = Double(self.goalDailyTime)
        newGoal.frequency = ""
        newGoal.id = UUID()

        // 3
        saveContext()
        
        self.isPresented = false
    }
}

struct NewGoalForm_Previews: PreviewProvider {
    static var previews: some View {
        NewGoalForm(isPresented: .constant(true))
    }
}
