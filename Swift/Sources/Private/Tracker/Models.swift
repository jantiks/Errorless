//
//  File.swift
//  
//
//  Created by Tigran on 29.01.23.
//

import Foundation

enum TrackEvent: String {
    case viewDidLoad
    case viewWillAppear
    case viewWillDisappear
    case viewDidLayoutSubviews
    case changeToPortrait
    case changeToLandscape
    case willEnterForeground
    case didBecomeActive
    case willResignActive
    case didEnterBackground
    case willTerminate
    case sceneDidDisconnect
    case didTakeScreeshot
    case callDisconnected
    case callDialing
    case incomingCall
    case callConnected
}

struct TrackEventRequestBody: Encodable {
    let date = Date().toString()
    let name: String
    let body: String
    
    init(name: String, body: String = "") {
        self.name = name
        self.body = body
    }
}

struct DumpRequestBody: Encodable {
    let date = Date().toString()
    let name: String
    let body: String
    
    init(name: String, body: String) {
        self.name = name
        self.body = body
    }
}

struct RecieveNotificationRequestBody: Encodable {
    let date = Date().toString()
    let title: String?
    let message: String?
}
