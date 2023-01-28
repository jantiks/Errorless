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

class TrackEventRequestBody: BaseRequestBody {
    let event: String
    
    init(event: String) {
        self.event = event
    }
}

class DumpRequestBody: BaseRequestBody {
    let eventName: String
    let body: String
    
    init(eventName: String, body: String) {
        self.eventName = eventName
        self.body = body
    }
}
