////
////  CreateMediaView.swift
////  GetMac
////
////  Created by M. De Vries on 16/06/2021.
////
//
//import Foundation
//import SwiftUI
//import UniformTypeIdentifiers
//
//struct CreateMediaView: View{
//    @State var Install: URL?
//    @State var VolumeName: String = ""
//    @State var load = false
//    var body: some View{
//        HStack{
//            VStack(alignment: .leading){
//                HStack{
//                    Button("createinstallmedia", action: {load.toggle()})
//                    if let path = Install?.path{
//                        Text("\(path)")
//                    }
//                }
//                TextField("Volume name", text: $VolumeName)
//            }
//            Button("Create", action:{
//                Install = Install?.appendingPathComponent("Contents/Resources/createinstallmedia")
//                print(Install?.path)
//                guard VolumeName != "" else {
//                    return
//                }
//
//                let prc = Process()
//                prc.executableURL = Install!
//                let vol = "--volume /Volumes/\(VolumeName)"
//                print(vol)
//                prc.arguments = [vol, "--nointeraction"]
////                let loop = RunLoop()
////                loop.run(mode: .modalPanel, before: <#T##Date#>)
//                do {
//                    try Process.run(Install!, arguments: [vol, "--nointeraction"], terminationHandler: { prc in
//                    })
//                } catch {
//                    print(error)
//                }
//            })
//        }.padding()
//        .fileImporter(isPresented: $load, allowedContentTypes: [.executable]) { result in
//            do {
//                Install = try result.get()
//            } catch {
//                print(error)
//            }
//        }
//        .navigationTitle("Create Install Media")
//    }
//}
