//
//  ModelsTests.swift
//  SpecialContentDetectionTests
//
//  Created by Tamer Pateer on 26/3/18.
//  Copyright © 2018 Atlassian. All rights reserved.
//

import XCTest
@testable import SpecialContentDetection

class ModelsTests: XCTestCase {
  
  func testNoMentionsContentEquality() {
    let content1 = MessageSpecialContent(mentions: nil, emoticons: nil, links: nil)
    let content2 = MessageSpecialContent(mentions: ["mention"], emoticons: nil, links: nil)
    
    XCTAssertNotEqual(content1, content2)
    XCTAssertNotEqual(content2, content1)
  }
  
  func testNoEmoticonsContentEquality() {
    let content1 = MessageSpecialContent(mentions: nil, emoticons: ["emoticon"], links: nil)
    let content2 = MessageSpecialContent(mentions: nil, emoticons: nil, links: nil)
    
    XCTAssertNotEqual(content1, content2)
    XCTAssertNotEqual(content2, content1)
  }
  
  func testNoLinksContentEquality() {
    let content1 = MessageSpecialContent(mentions: nil, emoticons: nil, links: [LinkContent(url: "url", title: "title")])
    let content2 = MessageSpecialContent(mentions: nil, emoticons: nil, links: nil)
    
    XCTAssertNotEqual(content1, content2)
    XCTAssertNotEqual(content2, content1)
  }
  
  func testEmptyContentEquality() {
    let content1 = MessageSpecialContent(mentions: nil, emoticons: nil, links: nil)
    let content2 = MessageSpecialContent(mentions: nil, emoticons: nil, links: nil)
    
    XCTAssertEqual(content1, content2)
    XCTAssertEqual(content2, content1)
  }
  
  func testFullContentEquality() {
    let content1 = MessageSpecialContent(mentions: ["mention"], emoticons: ["emoticon"], links: [LinkContent(url: "url", title: "title")])
    let content2 = MessageSpecialContent(mentions: ["mention"], emoticons: ["emoticon"], links: [LinkContent(url: "url", title: "title")])
    
    XCTAssertEqual(content1, content2)
    XCTAssertEqual(content2, content1)
  }
}
