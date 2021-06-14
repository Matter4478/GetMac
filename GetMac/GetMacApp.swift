//
//  GetMacApp.swift
//  GetMac
//
//  Created by Merlijn de Vries on 14/06/2021.
//

import SwiftUI

@main
struct GetMacApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
