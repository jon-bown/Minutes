//
//  ResetAppView.swift
//  Minutes
//
//  Created by Jonathan Bown on 2/6/21.
//

import SwiftUI
import CoreData

struct ResetAppView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentationMode
    
    @FetchRequest(
      // 2
      entity: Goal.entity(),
      // 3
      sortDescriptors: [
        NSSortDescriptor(keyPath: \Goal.priority, ascending: true)
      ]
    // 4
    ) var goals: FetchedResults<Goal>
    
    @FetchRequest(
        entity: GoalRecord.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \GoalRecord.name, ascending: true)
        ]
    ) var goalRecords: FetchedResults<GoalRecord>
    
    @State var simpleAlertMessageWithButtons = false
    
    var body: some View {
        //Reset all app data
        VStack{
            GroupBox{
                
                Button(action: {
                    //do an are you sure alert box
                    simpleAlertMessageWithButtons.toggle()

                }){
                    Text("Erase All Data").foregroundColor(Color.red).font(.system(size: 18, design: .rounded)).padding(4).cornerRadius(8).multilineTextAlignment(.leading)
                }.alert(isPresented: $simpleAlertMessageWithButtons, content: {
                    
                    let firstButton = Alert.Button.default(Text("Erase")){
                                        self.deleteAllGoals()
                                        self.deleteAllGoalRecords()
                        self.deleteAllNotifications()
                        self.presentationMode.wrappedValue.dismiss()
                    }
                     let secondButton = Alert.Button.destructive(Text("cancel"))
                     
                    return Alert(title: Text("Are you sure you want to erase goal data?"), primaryButton: firstButton, secondaryButton: secondButton)
                }).frame(width: UIScreen.main.bounds.width - 60)
            }.cornerRadius(15).padding()
            Spacer()
        }
       
    }
    
    
    
    func deleteAllGoals() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Goal")
        
        fetchRequest.includesPropertyValues = false
        
        do {
            let items = try managedObjectContext.fetch(fetchRequest) as! [Goal]
            
            for item in items {
                managedObjectContext.delete(item)
            }
            
            try managedObjectContext.save()
            
        } catch {
            // Error Handling
            // ...
        }
    }
    
    func deleteAllGoalRecords() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GoalRecord")
        fetchRequest.includesPropertyValues = false
        
        do {
            let items = try managedObjectContext.fetch(fetchRequest) as! [GoalRecord]
            
            for item in items {
                managedObjectContext.delete(item)
            }
            try managedObjectContext.save()
            
        } catch {
            // Error Handling
            // ...
        }
    }
    
    func deleteAllNotifications() {
        
    }
    
}

#if DEBUG
struct ResetAppView_Previews: PreviewProvider {
    static var previews: some View {
        ResetAppView()
    }
}
#endif
