//
//  mock_url_sessionTests.swift
//  mock_url_sessionTests
//
//  Created by Allar-Alexey Alexandrovich on 10/28/19.
//  Copyright © 2019 Allar-Alexey Alexandrovich. All rights reserved.
//

import XCTest
@testable import mock_url_session

class mock_url_sessionTests: XCTestCase {

    override func setUp() {
        URLProtocol.registerClass(MockResponseURLProtocol.self)
        MockResponseURLProtocol.chunksSize = 10
    }

    func googleLink() -> URL {
        guard let url = URL(string: "https://www.google.com") else {
            fatalError("Unconstructable URL")
        }
        
        return url
    }
    
    let mockResponse: Result<Data, Error> = .success(Data(repeating: 0, count: 2000))
    private var observation: NSKeyValueObservation?
    
    func testRequestExecution() {
        
        MockResponseURLProtocol.mockResponses[googleLink()] = mockResponse
        
        let expectation = XCTestExpectation(description: "task done")
        
        let task = URLSession.shared.dataTask(with: googleLink()) { _, _, _ in
            expectation.fulfill()
        }
        
        observation = task.progress.observe(\.fractionCompleted) { progress, _ in
            print("\(progress.completedUnitCount)", terminator: " ")
        }
        
        task.resume()
    }
    
   
    func testResponse() {
        MockResponseURLProtocol.mockResponses[googleLink()] = mockResponse
        
        let data = try! Data(contentsOf: googleLink())
        
        assert(data.count == 2000)
    }
}

