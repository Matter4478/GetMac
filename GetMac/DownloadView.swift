//
//  DownloadView.swift
//  GetMac
//
//  Created by M. De Vries on 15/06/2021.
//

import Foundation
import SwiftUI

struct DownloadView: View{
    let url: URL
    func startDownload(){
        let config = URLSessionConfiguration.default
        let task = URLSession(configuration: config).downloadTask(with: URLRequest(url: url)) { url, URLResponse, error in
            if let error = error{
                print(error)
                return
            }
            if let url = url{
                NSWorkspace.shared.open(url)
            }
        }
        task.resume()
    }
    @State var progress = Progress(totalUnitCount: 100)
    var body: some View{
        VStack{
            Text("Downloading...")
            ProgressView(progress)
        }.onAppear {
            startDownload()
        }
        .navigationTitle(Text("GetMac: Downloading..."))
    }
}
