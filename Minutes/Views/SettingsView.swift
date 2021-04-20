//
//  SettingsView.swift
//  Minutes
//
//  Created by Jonathan Bown on 10/7/20.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentationMode
    @FetchRequest(
      entity: Goal.entity(),
      sortDescriptors: [
        NSSortDescriptor(keyPath: \Goal.priority, ascending: true)
      ]
    ) var goals: FetchedResults<Goal>
    
    var buttonDisabled: Bool {
        return goals.count == 0
    }
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false){
                VStack(spacing: 20){
                    // MARK: - SECTION 1
                    GroupBox(label: Text("GOAL SETTINGS").bold()){
                        SettingsRowNavLinkView(navView: AnyView(GoalPriorityView()), label: "Edit Goals", enabled: buttonDisabled).disabled(buttonDisabled)
                        SettingsRowNavLinkView(navView: AnyView(ResetAppView()), label: "Reset", enabled: buttonDisabled).disabled(buttonDisabled)
                    }
                    // MARK: - SECTION 2
                    
                    GroupBox(label:
                                Text("APPLICATION").bold()
                    )
                    {
                        SettingsRowView(name: "Developer", content: "App Factorial LLC")
                        SettingsRowView(name: "Website", linkLabel: "App Factorial", linkDestination: "appfactorial.com")
                        SettingsRowView(name: "Version", content: "1.0")
                    }
                }

                // MARK: - SECTION 3
//                Section(header: Text("NOTIFICATIONS")){
//                    
//                }
            }.navigationTitle(Text("Settings")).navigationBarTitleDisplayMode(.large).padding()

        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
#endif
