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

    var body: some Scene {
        WindowGroup {
            ContentView().accentColor(.white)
                .environment(\.managedObjectContext, persistenceController.persistentContainer.viewContext)
        }
    }
}
