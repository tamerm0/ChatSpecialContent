//
//  MentionsDetectorTests.swift
//  SpecialContentDetectionTests
//
//  Created by Tamer Pateer on 24/3/18.
//  Copyright © 2018 Atlassian. All rights reserved.
//

import XCTest
import RxBlocking
@testable import SpecialContentDetection

class MentionsDetectorTests: XCTestCase {
  
  var detector: MentionsDetector!
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
    detector = MentionsDetector()
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testNoMentionsSucceeds() {
    guard let foundResults = try? detector.detect(in: "Hello, there is no mentions here!").toBlocking().toArray()
      else { XCTFail("Detection Fails"); return }
    
    XCTAssertEqual(foundResults.count, 0)
  }
  
  func testDetectionAtMessageStartSucceeds() {
    guard let foundResults = try? detector.detect(in: "@tamer Hello, there is one mention here!").toBlocking().toArray()
      else { XCTFail("Detection Fails"); return }
    
    guard foundResults.count == 1,
      case .mentionMatches(let mentions) = foundResults[0],
      mentions.count == 1
      else { XCTFail("No results returned"); return }
    
    XCTAssertEqual(mentions[0], "tamer")
  }
  
  func testDetectionAtMessageEndSucceeds() {
    guard let foundResults = try? detector.detect(in: "Hello, there is one mention at the end! @tamer").toBlocking().toArray()
      else { XCTFail("Detection Fails"); return }
    
    guard foundResults.count == 1,
      case .mentionMatches(let mentions) = foundResults[0],
      mentions.count == 1
      else { XCTFail("No results returned"); return }
    
    XCTAssertEqual(mentions[0], "tamer")
  }
  
  func testAlphanumericDetectionSucceeds() {
    guard let foundResults = try? detector.detect(in: "Hello @tamer6, there is one mention at the beginning!").toBlocking().toArray()
      else { XCTFail("Detection Fails"); return }
    
    guard foundResults.count == 1,
      case .mentionMatches(let mentions) = foundResults[0],
      mentions.count == 1
      else { XCTFail("No results returned"); return }
    
    XCTAssertEqual(mentions[0], "tamer6")
  }
  
  func testDetectionInWardsFails() {
    guard let foundResults = try? detector.detect(in: "Hello, that shouldn't be considered as a mention tamer.milad6@gmail.com").toBlocking().toArray()
      else { XCTFail("Detection Fails"); return }
    
    XCTAssertEqual(foundResults.count, 0)
  }
  
  func testDetectionAfterWhiteSpaceSucceeds() {
    guard let foundResults = try? detector.detect(in: "Hello @tamer, there is one mention at the end!").toBlocking().toArray()
      else { XCTFail("Detection Fails"); return }
    
    guard foundResults.count == 1,
      case .mentionMatches(let mentions) = foundResults[0],
      mentions.count == 1
      else { XCTFail("No results returned"); return }
    
    XCTAssertEqual(mentions[0], "tamer")
  }
  
  func testMutlipleMentionDetected() {
    guard let foundResults = try? detector.detect(in: "Hello @reviewer, there is one more mention at the end! @tamer").toBlocking().toArray()
      else { XCTFail("Detection Fails"); return }
    
    guard foundResults.count == 1,
      case .mentionMatches(let mentions) = foundResults[0],
      mentions.count == 2
      else { XCTFail("No results returned"); return }
    
    XCTAssertEqual(mentions[0], "reviewer")
    XCTAssertEqual(mentions[1], "tamer")
  }
  
  func testMapMatches() {
    let matches: [Substring] = ["reviewer", "tamer"]
    guard let mappedMatches = try? detector.map(matches: matches).toBlocking().toArray(),
      mappedMatches.count == 1,
      case .mentions(let mentions) = mappedMatches[0]
      else { XCTFail("Mapping failed"); return }
    XCTAssertEqual(mentions, matches.map { String($0) })
  }
  
}
