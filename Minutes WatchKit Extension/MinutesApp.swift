//
//  MinutesApp.swift
//  Minutes WatchKit Extension
//
//  Created by Jonathan Bown on 8/13/20.
//

import SwiftUI

@main
struct MinutesApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
