//
//  ChatContentJSONEncoderTests.swift
//  SpecialContentDetectionTests
//
//  Created by Tamer Pateer on 26/3/18.
//  Copyright © 2018 Atlassian. All rights reserved.
//

import XCTest
import OHHTTPStubs
import RxBlocking
@testable import SpecialContentDetection

class ChatContentJSONEncoderTests: XCTestCase {
  
  var detector: ChatContentJSONEncoder!
  
  override func setUp() {
    super.setUp()
    detector = ChatContentJSONEncoder()
  }
  
  func testFullContentJson() {
    let url = "http://www.google.com"
    stub(condition: isAbsoluteURLString(url)) { (request) -> OHHTTPStubsResponse in
      let string = "<title>Google Title</title>"
      return OHHTTPStubsResponse(data: string.data(using: .utf8)!, statusCode: 200, headers: nil)
    }
    
    guard let results = try? detector.detectContent(in: "@reviewer, (hello) this is a link, www.google.com").toBlocking().toArray(),
      results.count == 1
      else { XCTFail("Detection fails"); return }
    
    let decoder = JSONDecoder()
    let result = try! decoder.decode(MessageSpecialContent.self, from: results[0].data(using: .utf8)!)
    let content = MessageSpecialContent(mentions: ["reviewer"],
                                        emoticons: ["hello"],
                                        links: [LinkContent(url: "www.google.com",
                                                            title: "Google Title")])
    XCTAssertEqual(content, result)
  }
  
  func testNoLinksContentJson() {
    
    guard let results = try? detector.detectContent(in: "@reviewer, (hello) this is no link").toBlocking().toArray(),
      results.count == 1
      else { XCTFail("Detection fails"); return }
    
    let result = results[0]
    XCTAssertFalse(result.contains("links"))
  }
  
  func testNoMentionsContentJson() {
    let url = "http://www.google.com"
    stub(condition: isAbsoluteURLString(url)) { (request) -> OHHTTPStubsResponse in
      let string = "<title>Google Title</title>"
      return OHHTTPStubsResponse(data: string.data(using: .utf8)!, statusCode: 200, headers: nil)
    }
    
    guard let results = try? detector.detectContent(in: "(hello) this is a link, www.google.com").toBlocking().toArray(),
      results.count == 1
      else { XCTFail("Detection fails"); return }
    
    let result = results[0]
    XCTAssertFalse(result.contains("mentions"))
  }
  
  func testNoEmoticonsContentJson() {
    let url = "http://www.google.com"
    stub(condition: isAbsoluteURLString(url)) { (request) -> OHHTTPStubsResponse in
      let string = "<title>Google Title</title>"
      return OHHTTPStubsResponse(data: string.data(using: .utf8)!, statusCode: 200, headers: nil)
    }
    
    guard let results = try? detector.detectContent(in: "@reviewer, this is a link, www.google.com").toBlocking().toArray(),
      results.count == 1
      else { XCTFail("Detection fails"); return }
    
    let result = results[0]
    XCTAssertFalse(result.contains("emoticons"))
  }
}
