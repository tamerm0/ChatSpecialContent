//
//  LinkContentLoaderTests.swift
//  SpecialContentDetectionTests
//
//  Created by Tamer Pateer on 25/3/18.
//  Copyright © 2018 Atlassian. All rights reserved.
//

import XCTest
import RxBlocking
import OHHTTPStubs
@testable import SpecialContentDetection

class LinkContentLoaderTests: XCTestCase {
  
  var contentLoader: LinkContentLoaderImpl!
  
  override func setUp() {
    super.setUp()
    contentLoader = LinkContentLoaderImpl()
  }
  
  func testUrlWithScheme() {
    let url = "http://www.google.com"
    stub(condition: isAbsoluteURLString(url)) { (request) -> OHHTTPStubsResponse in
      let string = "<title>Google Title</title>"
      return OHHTTPStubsResponse(data: string.data(using: .utf8)!, statusCode: 200, headers: nil)
    }
    
    guard let results = try? contentLoader.linkContent(from: url).toBlocking().toArray(),
      results.count == 1
      else { XCTFail("Content load fail"); return }
    let content = results[0]
    XCTAssertEqual(content, LinkContent(url: url, title: "Google Title"))
  }
  
  func testUrlWithoutScheme() {
    let url = "www.google.com"
    stub(condition: isAbsoluteURLString("http://" + url)) { (request) -> OHHTTPStubsResponse in
      let string = "<title>Google Title</title>"
      return OHHTTPStubsResponse(data: string.data(using: .utf8)!, statusCode: 200, headers: nil)
    }
    
    guard let results = try? contentLoader.linkContent(from: url).toBlocking().toArray(),
      results.count == 1
      else { XCTFail("Content load fail"); return }
    let content = results[0]
    XCTAssertEqual(content, LinkContent(url: url, title: "Google Title"))
  }
  
  func testEmail() {
    let url = "tamer.milad6@gmail.com"
    stub(condition: isAbsoluteURLString("http://" + url)) { (request) -> OHHTTPStubsResponse in
      let string = "<title>Email</title>"
      return OHHTTPStubsResponse(data: string.data(using: .utf8)!, statusCode: 200, headers: nil)
    }
    
    guard let results = try? contentLoader.linkContent(from: url).toBlocking().toArray(),
      results.count == 1
      else { XCTFail("Content load fail"); return }
    let content = results[0]
    XCTAssertEqual(content, LinkContent(url: url, title: "Email"))
  }
  
  func testNetworkFailure() {
    let url = "http://www.google.com"
    stub(condition: isAbsoluteURLString(url)) { (request) -> OHHTTPStubsResponse in
      return OHHTTPStubsResponse(error: NSError(domain:"HTTPDomainError", code:404, userInfo:nil))
    }
    
    guard let results = try? contentLoader.linkContent(from: url).toBlocking().toArray(),
      results.count == 1
      else { XCTFail("Content load fail"); return }
    let content = results[0]
    XCTAssertEqual(content, LinkContent(url: url, title: nil))
  }
}
