//
//  SettingsView.swift
//  Minutes
//
//  Created by Jonathan Bown on 10/7/20.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            Form {
                
                // MARK: - SECTION 1
                Section(header: Text("GOAL SETTINGS")){
                    NavigationLink(destination: GoalPriorityView()){
                        Text("Goal Priorities")
                        Spacer()
                    }
                    NavigationLink(destination: ResetAppView()){
                        Text("Reset")
                        Spacer()
                    }
                }
                // MARK: - SECTION 2
                Section(header: Text("APPLICATION")){
                        SettingsRowView(name: "Developer", content: "App Factorial LLC")
 
                }
                // MARK: - SECTION 3
//                Section(header: Text("NOTIFICATIONS")){
//                    
//                }
            }.navigationBarTitle(Text("Settings"), displayMode: .large).padding()   

        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
