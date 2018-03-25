//
//  ChatContentDetectorTests.swift
//  SpecialContentDetectionTests
//
//  Created by Tamer Pateer on 26/3/18.
//  Copyright © 2018 Atlassian. All rights reserved.
//

import XCTest
import RxBlocking
import OHHTTPStubs
@testable import SpecialContentDetection

class ChatContentDetectorTests: XCTestCase {
  
  var detector: ChatContentDetector!
  var types: [ContentType]!
  
  override func setUp() {
    super.setUp()
    detector = ChatContentDetector()
    types = [.emoticon, .mention, .link]
  }
  
  func testFullContentDetection() {
    let url = "http://www.google.com"
    stub(condition: isAbsoluteURLString(url)) { (request) -> OHHTTPStubsResponse in
      let string = "<title>Google Title</title>"
      return OHHTTPStubsResponse(data: string.data(using: .utf8)!, statusCode: 200, headers: nil)
    }
    
    guard let results = try? detector.detectContent(in: "@reviewer, (hello) this is a link, www.google.com", types: types).toBlocking().toArray(),
      results.count == 1
      else { XCTFail("Detection fails"); return }
    
    let content = MessageSpecialContent(mentions: ["reviewer"], emoticons: ["hello"], links: [LinkContent(url: "www.google.com", title: "Google Title")])
    XCTAssertEqual(content, results[0])
  }
  
  func testNoContent() {
    guard let results = try? detector.detectContent(in: "No special content", types: types).toBlocking().toArray()
      else { XCTFail("Detection fails"); return }
    XCTAssertEqual(results.count, 0)
  }
  
  func testOverlaps() {
    let url = "https://www.google.com.sg/search?q=(hello)"
    stub(condition: isAbsoluteURLString(url)) { (request) -> OHHTTPStubsResponse in
      let string = "<title>Google Title</title>"
      return OHHTTPStubsResponse(data: string.data(using: .utf8)!, statusCode: 200, headers: nil)
    }
    guard let results = try? detector.detectContent(in: "@reviewer, this is a link, https://www.google.com.sg/search?q=(hello)", types: types).toBlocking().toArray(),
      results.count == 1
      else { XCTFail("Detection fails"); return }
    
    let content = MessageSpecialContent(mentions: ["reviewer"], emoticons: nil, links: [LinkContent(url: url, title: "Google Title")])
    XCTAssertEqual(content, results[0])
  }
  
  func testNoLinks() {
    guard let results = try? detector.detectContent(in: "@reviewer, (hello) this is no links", types: types).toBlocking().toArray(),
      results.count == 1
      else { XCTFail("Detection fails"); return }
    
    let content = MessageSpecialContent(mentions: ["reviewer"], emoticons: ["hello"], links: nil)
    XCTAssertEqual(content, results[0])
  }
  
  func testNoMentions() {
    let url = "http://www.google.com"
    stub(condition: isAbsoluteURLString(url)) { (request) -> OHHTTPStubsResponse in
      let string = "<title>Google Title</title>"
      return OHHTTPStubsResponse(data: string.data(using: .utf8)!, statusCode: 200, headers: nil)
    }
    
    guard let results = try? detector.detectContent(in: "hey @ reviewer, (hello) this is a link, www.google.com, btw, this is no mentions too", types: types).toBlocking().toArray(),
      results.count == 1
      else { XCTFail("Detection fails"); return }
    
    let content = MessageSpecialContent(mentions: nil, emoticons: ["hello"], links: [LinkContent(url: "www.google.com", title: "Google Title")])
    XCTAssertEqual(content, results[0])
  }
}
