//
//  MinutesApp.swift
//  Watch Minutes Extension
//
//  Created by Jonathan Bown on 1/14/21.
//

import SwiftUI

@main
struct MinutesApp: App {
    let persistenceController = PersistenceController.shared
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView().environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
    
    
    
}

