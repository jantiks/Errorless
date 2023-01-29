//
//  File.swift
//  
//
//  Created by Tigran on 29.01.23.
//

import Foundation

enum TrackEvent: String {
    case viewDidLoad, viewWillAppear, viewWillDisappear, changeToPortrait, changeToLandscape
}

class TrackEventRequestBody: Encodable {
    let date = Date().toString()
    let name: String
    let body: String
    
    init(name: String, body: String = "") {
        self.name = name
        self.body = body
    }
}

class DumpRequestBody: Encodable {
    let date = Date().toString()
    let name: String
    let body: String
    
    init(name: String, body: String) {
        self.name = name
        self.body = body
    }
}
