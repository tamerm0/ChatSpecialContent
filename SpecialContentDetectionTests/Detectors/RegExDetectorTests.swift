//
//  RegExDetectorTests.swift
//  SpecialContentDetectionTests
//
//  Created by Tamer Pateer on 24/3/18.
//  Copyright © 2018 Atlassian. All rights reserved.
//

import XCTest
import RxBlocking
@testable import SpecialContentDetection

class RegExDetectorTests: XCTestCase {

  
  func testCreateRegExWithValidPatternSucceeds() {
    let regExDetector = RegExDetector(pattern: "(string)")
    XCTAssertNotNil(regExDetector)
  }
  
  func testCreateRegExWithInvalidPatternFails() {
    let regExDetector = RegExDetector(pattern: "(")
    XCTAssertNil(regExDetector)
  }
  
  func testCreateDetectorWithRegExSucceeds() {
    guard let regEx = try? NSRegularExpression(pattern: "(string)", options: .caseInsensitive)
      else { XCTFail("Failed to create NSRegularExpression"); return }
    
    let regExDetector = RegExDetector(regEx: regEx)
    XCTAssertNotNil(regExDetector)
  }
  
  func testNoMatchesSucceeds() {
    guard let detector = RegExDetector(pattern: "[0,1,2,3,4,5,6,7,8,9]+")
      else { XCTFail("Failed to create Detector"); return }
    
    guard let foundMatches = try? detector.findMatches(in: "abc").toBlocking().toArray()
      else { XCTFail("No matches"); return }
    
    XCTAssertEqual(foundMatches.count, 0)
  }
  
  func testSingleMatchFoundSucceeds() {
    guard let detector = RegExDetector(pattern: "[0,1,2,3,4,5,6,7,8,9]+")
      else { XCTFail("Failed to create Detector"); return }
    
    guard let foundMatches = try? detector.findMatches(in: "123 abc").toBlocking().toArray()
      else { XCTFail("No matches"); return }
    
    guard foundMatches.count == 1 else { XCTFail("Many results received received"); return }
    let firstMatches = foundMatches[0]
    XCTAssertEqual(firstMatches.count, 1)
    XCTAssertEqual(firstMatches[0], "123")
  }
  
  func testMultiMatchesFoundSucceeds() {
    guard let detector = RegExDetector(pattern: "[0,1,2,3,4,5,6,7,8,9]+")
      else { XCTFail("Failed to create Detector"); return }
    
    guard let foundMatches = try? detector.findMatches(in: "123 08 abc 3010").toBlocking().toArray() else {
      XCTFail("No matches")
      return
    }
    guard foundMatches.count == 1 else { XCTFail("Many results received received"); return }
    let firstMatches = foundMatches[0]
    guard firstMatches.count == 3 else { XCTFail(); return }
    XCTAssertEqual(firstMatches[0], "123")
    XCTAssertEqual(firstMatches[1], "08")
    XCTAssertEqual(firstMatches[2], "3010")
  }
}
