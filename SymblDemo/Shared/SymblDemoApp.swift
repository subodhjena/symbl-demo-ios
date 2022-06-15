//
//  SymblDemoApp.swift
//  Shared
//
//  Created by Subodh Jena on 15/06/22.
//

import SwiftUI

@main
struct SymblDemoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
