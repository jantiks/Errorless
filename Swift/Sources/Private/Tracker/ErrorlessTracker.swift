//
//  ErrorlessTracker.swift
//  
//
//  Created by Tigran on 05.01.23.
//

import Foundation

struct ErrorlessTracker {
    
    enum TrackerError: Error {
        case invalidBody
    }
    
    public func dump(_ body: DumpRequestBody, completion: ((Result<BaseResponseBody, Error>) -> Void)? = nil) {
        ErrorlesNetworkManager("dump")
            .setHttpMethod(.post)
            .setJsonHeaders()
            .addAuthorization()
            .setBody(body)
            .startRequest(ofType: BaseResponseBody.self, completion: completion)
    }
    
    func trackRecieveNotification(body: RecieveNotificationRequestBody, completion: ((Result<BaseResponseBody, Error>) -> Void)? = nil) {
        ErrorlesNetworkManager("notification")
            .setHttpMethod(.post)
            .setJsonHeaders()
            .addAuthorization()
            .setBody(body)
            .startRequest(ofType: BaseResponseBody.self, completion: completion)
    }
    
    func track(_ event: TrackEvent, completion: ((Result<BaseResponseBody, Error>) -> Void)? = nil) {
        ErrorlesNetworkManager("event")
            .setHttpMethod(.post)
            .setJsonHeaders()
            .addAuthorization()
            .setBody(TrackEventRequestBody(name: event.rawValue))
            .startRequest(ofType: BaseResponseBody.self, completion: completion)
    }
    
    func track(_ event: TrackEvent, body: [String: String], completion: ((Result<BaseResponseBody, Error>) -> Void)? = nil) {
        ErrorlesNetworkManager("event")
            .setHttpMethod(.post)
            .setJsonHeaders()
            .addAuthorization()
            .setBody(TrackEventRequestBody(name: event.rawValue, body: body))
            .startRequest(ofType: BaseResponseBody.self, completion: completion)
    }
    
    func track(_ event: TrackEvent, body: Encodable, completion: ((Result<BaseResponseBody, Error>) -> Void)? = nil) {
        guard let bodyData = try? JSONEncoder().encode(body) else {
            completion?(.failure(TrackerError.invalidBody))
            return
        }
        
        ErrorlesNetworkManager("event")
            .setHttpMethod(.post)
            .setJsonHeaders()
            .addAuthorization()
            .setBody(AbstractTrackEventRequestBody(name: event.rawValue, body: bodyData))
            .startRequest(ofType: BaseResponseBody.self, completion: completion)
    }
}
