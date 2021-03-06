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
            ScrollView(.vertical, showsIndicators: false){
                VStack(spacing: 20){
                    // MARK: - SECTION 1
                    GroupBox(label: Text("GOAL SETTINGS").bold()){
                        SettingsRowNavLinkView(navView: AnyView(GoalPriorityView()), label: "Goal Priorities")
                        SettingsRowNavLinkView(navView: AnyView(ResetAppView()), label: "Reset")
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
            }.navigationBarTitle(Text("Settings"), displayMode: .large).padding()   

        }
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
#endif
