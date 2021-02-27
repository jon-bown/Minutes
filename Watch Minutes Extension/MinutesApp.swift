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
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self) var delegate
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView().environment(\.managedObjectContext, persistenceController.container.viewContext).environment(\.appDelegate, delegate)
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
    
    
    
}


struct DelegateKey: EnvironmentKey {
    typealias Value = ExtensionDelegate?
    static let defaultValue: ExtensionDelegate? = nil
}

extension EnvironmentValues {
    var appDelegate: DelegateKey.Value {
        get {
            return self[DelegateKey.self]
        }
        set {
            self[DelegateKey.self] = newValue
        }
    }
}
