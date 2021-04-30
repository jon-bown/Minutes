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
    
    @State var simpleAlertMessageWithButtons = false
    
    var body: some View {
        //Reset all app data
        VStack{
            
                
                Button(action: {
                    //do an are you sure alert box
                    simpleAlertMessageWithButtons.toggle()

                }){
                    GroupBox{
                        HStack{
                            Text("Erase All Data").foregroundColor( Color.red).font(.system(size: 18, design: .rounded)).padding(4).cornerRadius(8).multilineTextAlignment(.leading)
                            Spacer()
                        }

                        
                    }.cornerRadius(15).padding()
                }.alert(isPresented: $simpleAlertMessageWithButtons, content: {
                    self.simpleWarning()
                    let firstButton = Alert.Button.default(Text("Erase")){
                        self.deleteAllGoals()
                        self.deleteAllGoalRecords()
                        self.deleteAllNotifications()
                        self.presentationMode.wrappedValue.dismiss()
                    }
                     let secondButton = Alert.Button.destructive(Text("Cancel"))
                     
                    return Alert(title: Text("Are you sure you want to erase goal data?"), primaryButton: firstButton, secondaryButton: secondButton)
                }).frame(width: UIScreen.main.bounds.width - 60)
            
            Spacer()
        }
       
    }
    
    //MARK: HAPTICS
    func simpleWarning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
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
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
           var identifiers: [String] = []
           for notification:UNNotificationRequest in notificationRequests {
                  identifiers.append(notification.identifier)
           }
           UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
    
}

#if DEBUG
struct ResetAppView_Previews: PreviewProvider {
    static var previews: some View {
        ResetAppView()
    }
}
#endif
