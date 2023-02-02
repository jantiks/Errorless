//
//  File.swift
//  
//
//  Created by Tigran on 28.01.23.
//

import Foundation

final class ErrorlesNetworkManager {
    
    private var request: Request = Request()
    static var k_BASE_URL = "http://127.0.0.1:8000/"
    
    class Request {
        var path: URL? = nil
        var httpMethod: HttpMethod = .get
        var headers: [String: String] = [:]
        var body: Data? = nil
    }
    
    enum ManagerErrors: Error {
        case invalidResponse
        case invalidStatusCode(Int)
        case invalidRequest
        case invalidBody
    }
    
    enum HttpMethod: String {
        case get
        case post
        
        var method: String { rawValue.uppercased() }
    }
    
    init(_ endPoint: String) {
        request.path = URL(string: ErrorlesNetworkManager.k_BASE_URL + "\(endPoint)")
    }
    
    @discardableResult
    func setJsonHeaders() -> Self {
        request.headers["Content-Type"] = "application/json"
        addAuthorization()
        return self
    }
    
    @discardableResult
    func addCustomHeaders(_ headers: [String: String]) -> Self {
        headers.forEach { key, value in
            self.request.headers[key] = value
        }
        
        return self
    }
    
    @discardableResult
    func addAuthorization() -> Self {
        //        request.headers["Authorization"] = "ApiKey"
        return self
    }
    
    @discardableResult
    func setBody(_ data: Encodable) -> Self {
        request.body = try? JSONEncoder().encode(data)
        return self
    }
    
    @discardableResult
    func setHttpMethod(_ method: HttpMethod) -> Self {
        request.httpMethod = method
        return self
    }
    
    func startRequest<T: Decodable>(ofType: T.Type, completion: ((Result<T, Error>) -> Void)? = nil) {
        
        guard let request = initalizeRequest() else {
            completion?(.failure(ManagerErrors.invalidRequest))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            defer {
                self.request = Request()
            }
            
            if let error = error {
                completion?(.failure(error))
                return
            }

            guard let urlResponse = response as? HTTPURLResponse else { completion?(.failure(ManagerErrors.invalidResponse)); return }
            if !(200..<300).contains(urlResponse.statusCode) {
                completion?(.failure(ManagerErrors.invalidStatusCode(urlResponse.statusCode)))
                return
            }

            guard let data = data else { return }
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion?(.success(decodedData))
            } catch {
                debugPrint("Could not translate the data to the requested type. Reason: \(error.localizedDescription)")
                completion?(.failure(error))
            }
        }.resume()
    }
    
    private func initalizeRequest() -> URLRequest? {
        guard let url = request.path else { return nil }
        var httpRequest = URLRequest(url: url)
        httpRequest.httpMethod = request.httpMethod.method
        httpRequest.httpBody = request.body
        request.headers.forEach { key, value in
            httpRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        return httpRequest
    }
}
