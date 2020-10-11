//
//  ContentView.swift
//  Daily Minutes
//
//  Created by Jonathan Bown on 8/13/20.
//

import SwiftUI

struct ContentView: View {
    

    var body: some View {

        TabView{
            MainProgressView().tabItem {
                Image(systemName: "list.dash")
                Text("Summary")
            }
            
            CompletionView().tabItem{
                Image(systemName: "calendar")
                Text("History")
            }
            
            SettingsView().tabItem{
                Image(systemName: "gear")
                Text("Settings")
            }
        }
            
            
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
