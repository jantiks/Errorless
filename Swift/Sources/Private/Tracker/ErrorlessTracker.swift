//
//  ErrorlessTracker.swift
//  
//
//  Created by Tigran on 05.01.23.
//

import Foundation

struct ErrorlessTracker {
    
    public func dump(_ body: DumpRequestBody, completion: ((Result<BaseResponseBody, Error>) -> Void)? = nil) {
        ErrorlesNetworkManager("dump")
            .setHttpMethod(.post)
            .setJsonHeaders()
            .addAuthorization()
            .setBody(body)
            .startRequest(ofType: BaseResponseBody.self, completion: completion)
    }
    
    func track(_ event: TrackEvent) {
        ErrorlesNetworkManager("event")
            .setHttpMethod(.post)
            .setJsonHeaders()
            .addAuthorization()
            .setBody(TrackEventRequestBody(event: event.rawValue))
            .startRequest(ofType: BaseResponseBody.self)
    }
}
