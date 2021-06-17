//
//  GetMacApp.swift
//  GetMac
//
//  Created by Merlijn de Vries on 14/06/2021.
//

import SwiftUI
import Cocoa



class AppDelegate: NSObject, NSApplicationDelegate{
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("welcome in...")
    }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
}

@main
struct GetMacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let persistenceController = PersistenceController.shared
    @Environment(\.openURL) var openURL
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .frame(width: 200, height: 500, alignment: .center)
        }
        WindowGroup("Download"){
            DownloadView()
                .frame(width: 400, height: 100, alignment: .center)
        }
        .handlesExternalEvents(matching: ["Download"])
//        WindowGroup("CreateInstall"){
//            CreateMediaView()
//        }.handlesExternalEvents(matching: ["CreateInstallMedia"])
    }
}

let download = Download()

class Download: ObservableObject{
    @Published var Packages: [String:[Package]] = [:]
}
