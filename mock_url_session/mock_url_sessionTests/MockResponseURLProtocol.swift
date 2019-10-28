//
//  MockURLSession.swift
//  mock_url_sessionTests
//
//  Created by Allar-Alexey Alexandrovich on 10/28/19.
//  Copyright © 2019 Allar-Alexey Alexandrovich. All rights reserved.
//

import Foundation

class MockResponseURLProtocol: URLProtocol {
    static var chunksSize: Int = 0
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        // Overriding this function is required by the superclass.
        return request
    }
    
    override func startLoading() {
        guard let response = MockResponseURLProtocol.mockResponses[self.request.url!] else {
            fatalError(
                "No mock response for \(request.url!). This should never happen. Check " +
                "the implementation of `canInit(with request: URLRequest) -> Bool`"
            )
        }
        
        // Simulate the response on a background thread.
        DispatchQueue.global(qos: .default).async {
            switch response {
            case let .success(data):
                let response = URLResponse(
                    url: self.request.url!,
                    mimeType: nil,
                    expectedContentLength: data.count,
                    textEncodingName: nil
                )
                
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                
                // Step 2: Split data into chunks
                let chunkSize = MockResponseURLProtocol.chunksSize
                let chunks = stride(from: 0, to: data.count, by: chunkSize).map {
                    data[$0 ..< min($0 + chunkSize, data.count)]
                }
                
                // Step 3: Simulate received data chunk by chunk.
                for chunk in chunks {
                    self.client?.urlProtocol(self, didLoad: chunk)
                }
                
                // Step 4: Finish loading (required).
                self.client?.urlProtocolDidFinishLoading(self)
                
            case let .failure(error):
                // Simulate error.
                self.client?.urlProtocol(self, didFailWithError: error)
            }
        }
    }
    
    override func stopLoading() {
        // Required by the superclass.
    }
    
    static var mockResponses: [URL: Result<Data, Error>] = [:]
    
    override class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url else { return false }
        return mockResponses.keys.contains(url)
    }
}

