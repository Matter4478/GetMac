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
    @Environment(\.openURL) var openURL
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        WindowGroup("Download"){
            DownloadView()
        }
        .handlesExternalEvents(matching: Set(arrayLiteral: "*"))
    }
}

let download = Download()

class Download: ObservableObject{
    @Published var Packages: [String:[Package]] = [:]
}
