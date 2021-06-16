//
//  DownloadView.swift
//  GetMac
//
//  Created by M. De Vries on 15/06/2021.
//

import Foundation
import SwiftUI

var dateLong: DateFormatter{
    let tmp = DateFormatter()
    tmp.dateStyle = .full
    return tmp
}

struct DownloadView: View{
    @State var uuid: String = ""
    @State var originalCount: Int = 0
    @State var count: Int = 0
    @Environment(\.presentationMode) var presentationMode
    func downloadSequence(){
        var target = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        target = target.appendingPathComponent("GetMac/", isDirectory: true)
        print(target)
        if !FileManager.default.fileExists(atPath: target.path){
            do {
                var date = dateLong.string(from: Date())
                date = date.replacingOccurrences(of: "/", with: "-")
                target = target.appendingPathComponent("\(date)/", isDirectory: true)
                print(target)
                try FileManager.default.createDirectory(atPath: target.path, withIntermediateDirectories: true, attributes: [:])
            } catch {
                print(error)
                return
            }
        }
        let packages = download.Packages[uuid]!
        count = packages.count
        originalCount = packages.count
        progress = Progress(totalUnitCount: Int64(originalCount))
        packages.forEach({ pack in
            startDownload(url: URL(string: pack.URL)!, target: target, targetPathComponent: URL(string: pack.URL)!.lastPathComponent)
        })
    }
    func startDownload(url: URL, target: URL, targetPathComponent: String){
        let config = URLSessionConfiguration.default
        let task = URLSession(configuration: config).downloadTask(with: URLRequest(url: url)) { url, URLResponse, error in
            if let error = error{
                print(error)
                return
            }
            if let url = url{
                do {
                    print(url)
                    print(targetPathComponent)
                    try FileManager.default.copyItem(at: url, to: target.appendingPathComponent(targetPathComponent))
                } catch {
                    print(error)
                }
            }
            count -= 1
        }
        task.resume()
    }
    @State var progress = Progress()
    var body: some View{
        VStack{
            HStack{
                ProgressView(progress).padding()
                ProgressView().padding()
            }
        }
        .padding()
        .onOpenURL(perform: { url in
            uuid = url.query!
            downloadSequence()
        })
//        .onAppear {
//            startDownload()
//        }
        .navigationTitle(Text("GetMac: Downloading..."))
        .onChange(of: count) { newValue in
            progress.completedUnitCount = Int64(originalCount - count)
            if originalCount + count == 0{
                self.presentationMode.wrappedValue.dismiss()
                var target = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
                target = target.appendingPathComponent("GetMac/", isDirectory: true)
                NSWorkspace.shared.open(target)
            }
        }
    }
}
