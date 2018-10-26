//
//  YelpAPIClient.swift
//
//  Created by Kasey Schindler on 10/19/18.
//  Copyright © 2018 Curiously Creative, LLC. All rights reserved.
//

import Foundation

public final class YelpAPIClient {
    /// A wrapper around the response determining a success or failure
    /// - success returns the expected type defined by the request
    /// - failure returns an error
    public enum YelpResult<T: Decodable> {
        case success(T)
        case failure(YelpError.ErrorType)
    }
    
    private let yelpBaseUrl = URL(string: "https://api.yelp.com/v3")!
    private let apiKey = "YOUR_API_KEY_HERE"
    
    lazy private var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["Authorization" : "Bearer \(apiKey)", "Content-Type" : "application/json", "Accept" : "application/json"]
        
        return URLSession(configuration: configuration)
    }()
    
    public init() {}
    
    public func request<T: YelpAPIRequest>(request: T, completion: @escaping (YelpResult<T.Response>) -> ()) {
        var urlRequest = URLRequest(url: endpoint(for: request))
        urlRequest.httpMethod = "GET"
        
        let task = session.dataTask(with: urlRequest) { data, response, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let decodedResponse = try decoder.decode(T.Response.self, from: data)
                    
                    DispatchQueue.main.async {
                        completion(.success(decodedResponse))
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        print(error.localizedDescription)
                        completion(.failure(YelpError.ErrorType.error(error.localizedDescription)))
                    }
                }
            } else if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(YelpError.ErrorType.error(error.localizedDescription)))
                }
            }
        }
        task.resume()
    }
    
    private func endpoint<T: YelpAPIRequest>(for request: T) -> URL {
        guard let requestUrl = URL(string: "\(yelpBaseUrl)\(request.endpoint)") else {
            fatalError("Invalid endpoint: \(request.endpoint)")
        }
        
        guard let parameters = try? URLQueryItemEncoder.encode(request) else {
            fatalError("Invalid parameter encoding: \(request.endpoint)")
        }
        
        guard var components = URLComponents(url: requestUrl, resolvingAgainstBaseURL: true) else {
            fatalError("Invalid components: \(request.endpoint)")
        }
        
        components.queryItems = parameters
        
        return components.url!
    }
}