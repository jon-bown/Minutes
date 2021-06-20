//
//  SettingsView.swift
//  Minutes
//
//  Created by Jonathan Bown on 10/7/20.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var goalListVM = GoalListViewModel()
    
    var buttonDisabled: Bool {
        return goalListVM.getGoalsArray().count == 0
    }
    
    @State private var completionNotifications: Bool = UserDefaults.standard.bool(forKey: Constants.generalCompletionReminder)
    
    
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
                GroupBox(label: Text("NOTIFICATIONS").bold()){
                    VStack{
                        Divider().padding(.vertical,4)
                    
                            Toggle(isOn: self.$completionNotifications){
                                Text("100% Completion Notifications")
                            }
                            
                       
                            
                        
                    }
                }
            }.navigationTitle(Text("Settings")).navigationBarTitleDisplayMode(.large).padding()
            .onChange(of: self.completionNotifications){ newValue in
                UserDefaults.standard.set(self.completionNotifications, forKey: Constants.generalCompletionReminder)
            }

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
