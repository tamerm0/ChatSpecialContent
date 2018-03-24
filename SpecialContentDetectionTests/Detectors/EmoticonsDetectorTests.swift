//
//  EmoticonsDetectorTests.swift
//  SpecialContentDetectionTests
//
//  Created by Tamer Pateer on 25/3/18.
//  Copyright © 2018 Atlassian. All rights reserved.
//

import XCTest
import RxBlocking
@testable import SpecialContentDetection

class EmoticonsDetectorTests: XCTestCase {
  
  var detector: EmoticonsDetector!
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
    detector = EmoticonsDetector()
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testNoEmoticonsSucceeds() {
    guard let foundResults = try? detector.detect(in: "Hello, there is no emoticons here!").toBlocking().toArray()
      else { XCTFail("Detection Fails"); return }
    
    XCTAssertEqual(foundResults.count, 0)
  }
  
  func testDetectionAtMessageStartSucceeds() {
    guard let foundResults = try? detector.detect(in: "(Hello), there is one emoticon here!").toBlocking().toArray()
      else { XCTFail("Detection Fails"); return }
    
    guard foundResults.count == 1,
      case .emoticonMatches(let emoticons) = foundResults[0],
      emoticons.count == 1
      else { XCTFail("No results returned"); return }
    
    XCTAssertEqual(emoticons[0], "Hello")
  }
  
  func testDetectionAtMessageEndSucceeds() {
    guard let foundResults = try? detector.detect(in: "Hello, there is one emoticon at the end! (emo)").toBlocking().toArray()
      else { XCTFail("Detection Fails"); return }
    
    guard foundResults.count == 1,
      case .emoticonMatches(let emoticons) = foundResults[0],
      emoticons.count == 1
      else { XCTFail("No results returned"); return }
    
    XCTAssertEqual(emoticons[0], "emo")
  }
  
  func testDetectionAfterWhiteSpaceSucceeds() {
    guard let foundResults = try? detector.detect(in: "Hey (hello), there is one emoticon after white space!").toBlocking().toArray()
      else { XCTFail("Detection Fails"); return }
    
    guard foundResults.count == 1,
      case .emoticonMatches(let emoticons) = foundResults[0],
      emoticons.count == 1
      else { XCTFail("No results returned"); return }
    
    XCTAssertEqual(emoticons[0], "hello")
  }
  
  func testDetectionInWardsSucceeds() {
    guard let foundResults = try? detector.detect(in: "Hey(hello), there is one emoticon!").toBlocking().toArray()
      else { XCTFail("Detection Fails"); return }
    
    guard foundResults.count == 1,
      case .emoticonMatches(let emoticons) = foundResults[0],
      emoticons.count == 1
      else { XCTFail("No results returned"); return }
    
    XCTAssertEqual(emoticons[0], "hello")
  }
  
  func testAlphanumericDetected() {
    guard let foundResults = try? detector.detect(in: "Hey(hello123), there is one emoticon!").toBlocking().toArray()
      else { XCTFail("Detection Fails"); return }
    
    guard foundResults.count == 1,
      case .emoticonMatches(let emoticons) = foundResults[0],
      emoticons.count == 1
      else { XCTFail("No results returned"); return }
    
    XCTAssertEqual(emoticons[0], "hello123")
  }
  
  func testMoreThan15CharNotDetectedSucceeds() {
    guard let foundResults = try? detector.detect(in: "Hello, that shouldn't be considered as a emoticon (emoticonmorethan15char)").toBlocking().toArray()
      else { XCTFail("Detection Fails"); return }
    
    XCTAssertEqual(foundResults.count, 0)
  }
  
  func testMutlipleEmoticonDetected() {
    guard let foundResults = try? detector.detect(in: "(Hello) @reviewer, there is one more emoticon at the end! (thanks)").toBlocking().toArray()
      else { XCTFail("Detection Fails"); return }
    
    guard foundResults.count == 1,
      case .emoticonMatches(let emoticons) = foundResults[0],
      emoticons.count == 2
      else { XCTFail("No results returned"); return }
    
    XCTAssertEqual(emoticons[0], "Hello")
    XCTAssertEqual(emoticons[1], "thanks")
  }
  
  func testMapMatches() {
    let matches: [Substring] = ["hello", "thanku"]
    guard let mappedMatches = try? detector.map(matches: matches).toBlocking().toArray(),
      mappedMatches.count == 1,
      case .emoticons(let emoticons) = mappedMatches[0]
      else { XCTFail("Mapping failed"); return }
    XCTAssertEqual(emoticons, matches.map { String($0) })
  }
}
