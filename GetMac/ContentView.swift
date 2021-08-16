//
//  ContentView.swift
//  GetMac
//
//  Created by Merlijn de Vries on 14/06/2021.
//

import SwiftUI
import CoreData
import Foundation
import Cocoa

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
//        animation: .default)
//    private var items: FetchedResults<Item>
    
    @State var versions: [String] = []
    @State var sheet = false
    @State var catalogString = ""
    func loadVersions(){
        
    }
    @State var catalog = Catalog(CatalogVersion: 0, ApplePostURL: "", IndexDate: Date(), Products: [:])
    @State var productDict: [String:Product] = [:]
    func downloadParseSuCatalog(url: URL){
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)){ data, response, error in
            if let data = data {
                print("succes")
                do {
                    catalog = try PropertyListDecoder().decode(Catalog.self, from: data)
                } catch {
                    print(error)
                }
            } else {
                print(String(describing: error))
                print(String(describing: response))
            }
        }
        task.resume()
    }
    
    func getList(){
        productDict.removeAll()
            for product in catalog.Products{
                if product.value.ExtendedMetaInfo?.InstallAssistantPackageIdentifiers != nil && product.value.ServerMetadataURL != nil{
                    let task = URLSession(configuration: URLSessionConfiguration.default).dataTask(with: URLRequest(url: URL(string: product.value.ServerMetadataURL!)!)) { data, response, error in
                        if let data = data {
                            do {
                            let meta = try PropertyListDecoder().decode(ServerMetaData.self, from: data)
                                productDict[meta.CFBundleShortVersionString] = product.value
                            } catch {
                                print(error)
                            }
                        }
                    }
                    task.resume()
                } else if product.value.ExtendedMetaInfo?.InstallAssistantPackageIdentifiers != nil && product.value.ExtendedMetaInfo?.InstallAssistantPackageIdentifiers?.InstallInfo != nil{
                    let pack = product.value.Packages.first { pkg in
                        if URL(string: pkg.URL)?.lastPathComponent == "BuildManifest.plist"{
                            return true
                        } else {
                            return false
                        }
                    }
                    let task = URLSession(configuration: URLSessionConfiguration.default).dataTask(with: URLRequest(url: URL(string: (pack?.URL)!)!)) { data, response, error in
                        if let data = data {
                            do {
                                let meta = try PropertyListDecoder().decode(Digest.self, from: data)
                                productDict[meta.ProductVersion] = product.value
                            } catch {
                                print(error)
                            }
                        }
                    }
                    task.resume()
                }
        }
    }

    @Environment(\.openURL) var openURL
    var body: some View {
        List {
            ForEach(productDict.keys.sorted(by: >), id: \.self) { key in
                    HStack{
                        Text("macOS: \(key)")
                            .contextMenu{
                                ForEach(productDict[key]!.Distributions.sorted(by: >), id:\.key){ product in
                                    Button("\(product.key)", action:{
                                        let uuid = UUID().uuidString
                                        download.Packages[uuid] = [Package(Size: 0, URL: product.value, Digest: nil, MetadataURL: nil)]
                                        let url = URL(string: "GetMac://Download?\(uuid)")
                                        openURL(url!)
                                    })
                                            Text(product.value)
                                    }
                                ForEach(productDict[key]!.Packages, id:\.self){ product in
                                    Button("\(product.URL)", action:{
                                        let uuid = UUID().uuidString
                                        download.Packages[uuid] = [product]
                                        let url = URL(string: "GetMac://Download?\(uuid)")
                                        openURL(url!)
                                    })
//                                    Text("URL: \(product.URL), size: \(product.Size)")
                                    }
                            }
                        Spacer()
                            Button("Download", action:{
                                let uuid = UUID().uuidString
                                download.Packages[uuid] = productDict[key]!.Packages
                                let url = URL(string: "GetMac://Download/?\(uuid)")
                                openURL(url!)
                            })
                }
                Divider()
            }
        }
        .toolbar {
//            Button(action: {sheet.toggle()}) {
//                Label("Add Item", systemImage: "plus")
//            }
            Button("GitHub", action: {
                _ = NSWorkspace.shared.open(URL(string: "https://github.com/Matter4478/GetMac")!)
            })
            Button("Dortania Guides", action: {
                _ = NSWorkspace.shared.open(URL(string: "https://dortania.github.io")!)
            })
            Button("Disk Utility", action:{
                _ = NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/Utilities/Disk Utility.app"))
            })
            Button("Create Install Media", action: {
                openURL(URL(string: "GetMac://CreateInstallMedia")!)
            })
            Button(action:{
                downloadParseSuCatalog(url: URL(string: "https://swscan.apple.com/content/catalogs/others/index-11-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog")!)
            }){
                Label("Reload", systemImage: "arrow.clockwise")
            }
        }
        .onAppear {
            downloadParseSuCatalog(url: URL(string: "https://swscan.apple.com/content/catalogs/others/index-11-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog")!)
        }
        .onChange(of: catalog, perform: { _ in
            getList()
        })
        .navigationTitle(Text("GetMac"))
        .sheet(isPresented: $sheet, onDismiss: nil) {
            ScrollView{
                TextField("URL", text: $catalogString)
                Button("OK", action: {sheet.toggle()})
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}


//adaptation of installinstallmacos

func readPLIST(url: URL){
    
}

struct Catalog: Codable, Hashable, Equatable{
    let CatalogVersion: Int
    let ApplePostURL: String
    let IndexDate: Date
    let Products: [String:Product]
}

struct Product: Codable, Hashable{
    let ServerMetadataURL: String?
    let Packages: [Package]
    let PostDate: Date
    let Distributions: [String:String]
    let ExtendedMetaInfo: ExtendedMeta?
}
struct Package: Codable, Hashable{
    let Size: Int
    let URL: String
    let Digest: String?
    let MetadataURL: String?
}
//struct Details: Codable{
//    let InstallAssistantPackageIdentifiers:
//}
struct MetaContainer: Codable, Hashable{
    let InstallAssistantPackageIdentifiers: [String:ExtendedMeta]?
}
struct ExtendedMeta: Codable, Hashable{
    let InstallAssistantPackageIdentifiers: InstallAssistantPackageId?
    let ProductType: String?
    let ProductVersion: String?
    let AutoUpdate: String?
}

struct InstallAssistantPackageId: Codable, Hashable{
    let InstallInfo: String?
    let OSInstall: String?
}
struct PackageMetaInfo: Codable, Hashable{
    let InstallInfo: String?
    let OSInstall: String?
    let ProductVersion: String?
    let AutoUpdate: String?
    let SharedSupport: String?
}

struct ServerMetaData: Codable, Hashable{
    let CFBundleShortVersionString: String
}

struct Digest: Codable, Hashable{
    let ProductVersion: String
}
