//
//  RemoteYouTubeClient.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 29.08.23.
//

import Foundation

@available(iOS 13.0, watchOS 6.0, tvOS 13.0, macOS 10.15, *)
class RemoteYouTubeClient {
    
    let serverURL: URL
    
    init(serverURL: URL) {
        self.serverURL = serverURL
    }
    
    func extractStreams(forVideoID videoID: String) async throws -> [RemoteStream] {
        
        var urlComponents = URLComponents(url: serverURL.appendingPathComponent("v1"), resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = [
            URLQueryItem(name: "videoID", value: videoID)
        ]
        
        let websocketRequest = URLRequest(url: urlComponents.url!)
        
        let task = URLSession.shared.webSocketTask(with: websocketRequest)
        task.resume()
        
        defer {
            task.cancel()
        }
        
        struct RemoteURLRequest: Decodable {
            let url: URL
            let method: String
            let body: Data?
            let headers: [String: String]
            let allowRedirects: Bool
            let applyCookiesOnRedirect: Bool
            let saveIntermediateResponses: Bool
            
            var urlRequest: URLRequest {
                var request = URLRequest(url: url)
                request.httpMethod = method
                for (key, value) in headers {
                    request.setValue(value, forHTTPHeaderField: key)
                }
                if let body = body {
                    request.httpBody = body
                }
                return request
            }
        }
        
        struct RemoteURLResponse: Encodable {
            let url: URL?
            let data: Data
            let statusCode: Int?
            let headers: [String: String]
            var intermediates: [RemoteURLResponse]?
            
            init(data: Data, response: URLResponse) {
                self.url = response.url
                self.data = data
                let httpResponse = response as? HTTPURLResponse
                self.statusCode = httpResponse?.statusCode
                
                var headers = [String: String]()
                for (key, value) in httpResponse?.allHeaderFields ?? [:] {
                    guard let key = key as? String, let value = value as? String else { continue }
                    headers[key] = value
                }
                self.headers = headers
            }
        }
        
        enum ServerMessageType: String, Decodable {
            case urlRequest, result
        }
        
        struct ServerMessageBase: Decodable {
            let type: ServerMessageType
        }
        
        struct ServerMessage<Content: Decodable>: Decodable {
            let type: ServerMessageType
            let content: Content
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        while true {
            let message = try await task.receive()
            let messageType = try decoder.decode(ServerMessageBase.self, from: message).type
            
            switch messageType {
            case .result:
                let serverMessage = try decoder.decode(ServerMessage<[RemoteStream]>.self, from: message)
                return serverMessage.content
                
            case .urlRequest:
                let serverMessage = try decoder.decode(ServerMessage<RemoteURLRequest>.self, from: message)
                let request = serverMessage.content
                
                if !request.allowRedirects || request.applyCookiesOnRedirect {
                    let configuration = URLSessionConfiguration.default
                    let delegate = ConfigurableURLSessionDelegate(allowsRedirect: request.allowRedirects, applyCookiesOnRedirect: request.applyCookiesOnRedirect, saveIntermediateResponses: request.saveIntermediateResponses)
                    let session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
                    let (data, response) = try await session.data(for: request.urlRequest)
                    
                    var remoteResponse = RemoteURLResponse(data: data, response: response)
                    if request.saveIntermediateResponses {
                        remoteResponse.intermediates = delegate.intermediateResponses.map { RemoteURLResponse(data: Data(), response: $0) }
                    }
                    try await task.send(remoteResponse, encoder: encoder)
                } else {
                    let (data, response) = try await URLSession.shared.data(for: request.urlRequest)
                    try await task.send(RemoteURLResponse(data: data, response: response), encoder: encoder)
                }
            }
        }
    }
    
}
