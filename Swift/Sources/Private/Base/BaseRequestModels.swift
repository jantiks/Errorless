//
//  File.swift
//  
//
//  Created by Tigran on 29.01.23.
//

import Foundation

struct BaseResponseBody: Decodable {
    let message: String?
}

class BaseRequestBody: Encodable {
    let date = Date()
}
