//
//  CreateMediaView.swift
//  GetMac
//
//  Created by M. De Vries on 16/06/2021.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import SecurityFoundation
import SecurityInterface
import EndpointSecurity
import Cocoa

struct CreateMediaView: View{
    @State var Install: URL?
    @State var VolumeName: String = ""
    @State var load = false
    @State var warning = false
    @State var progress = false
    func create(){
        progress = true
        let vol = "--volume /Volumes/\(VolumeName)/"
        guard Install != nil else { return }
        let string = "\(Install!.absoluteURL) \(vol)"
        print(string)
        print(vol)
        let rights = auth.authorizationRights()!
        print(rights)

        do {
            let prc = Process()
            prc.executableURL = Bundle.main.bundleURL.appendingPathComponent("Contents/Resources/CreateMediaScript.app/Contents/MacOS/Automator Application Stub")
            prc.arguments = [Install!.path, vol]
            prc.qualityOfService = .userInteractive
            
            try prc.run()
            progress = false

        } catch {
            print(error)
            progress = false
        }
        

    }
    
    @State var auth = SFAuthorizationView()
    var body: some View{
        HStack{
            AuthView(auth: $auth)
            VStack(alignment: .leading){
                HStack{
                    Button("createinstallmedia", action: {load.toggle()})
                    if let path = Install?.path{
                        Text("\(path)")
                    }
                }
                TextField("Volume name", text: $VolumeName)
                if progress == true{
                    ProgressView()
                }
            }
            Button("Create", action:{
                Install = Install?.appendingPathComponent("Contents/Resources/createinstallmedia")
                print(String(describing: Install?.path))
                guard VolumeName != "" else {
                    return
                }
                warning = true
            })
        }.padding()
        .fileImporter(isPresented: $load, allowedContentTypes: [.executable]) { result in
            do {
                Install = try result.get()
            } catch {
                print(error)
            }
        }
        .alert(isPresented: $warning){
            Alert(title: Text("Erase Disk"), message: Text("Are you sure? Do you want to erase /Volumes/\(VolumeName)"), primaryButton: .cancel(), secondaryButton: .destructive(Text("Yes"), action: create)
            )}
        .navigationTitle("Create Install Media")
    }
}

struct AuthView: NSViewRepresentable{
    @Binding var auth: SFAuthorizationView
    func makeNSView(context: Context) -> SFAuthorizationView {
        auth.setFlags([AuthorizationFlags.extendRights, AuthorizationFlags.preAuthorize])
        auth.setString(kAuthorizationRightExecute)
        return auth
    }
    
    func updateNSView(_ nsView: SFAuthorizationView, context: Context) {
        //
    }
        
//    func makeCoordinator() -> Coordinator{
//        <#code#>
//    }
//
//    class Coordinator: NSObject, SFA
}


