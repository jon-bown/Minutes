//
//  MinutesApp.swift
//  Minutes
//
//  Created by Jonathan Bown on 1/9/21.
//

import SwiftUI

@main
struct MinutesApp: App {
    let persistenceController = PersistenceController.self
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView().accentColor(.white)
                .environment(\.managedObjectContext, persistenceController.persistentContainer.viewContext)
        }.onChange(of: scenePhase) { (newScenePhase) in
            switch newScenePhase {
            case .active:
                UIApplication.shared.applicationIconBadgeNumber = 0
                break
            case .inactive:
                break
            case .background:
                break
            @unknown default:
                break
                //print("Apple must have added something new!")
            }
        }
    }
}
