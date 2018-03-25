//
//  LinksDetectorTests.swift
//  SpecialContentDetectionTests
//
//  Created by Tamer Pateer on 25/3/18.
//  Copyright © 2018 Atlassian. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking
@testable import SpecialContentDetection

class LinksDetectorTests: XCTestCase {
  var detector: LinksDetector!
  var mockLinkContentLoader: MockLinkContentLoader!
  
  override func setUp() {
    super.setUp()
    mockLinkContentLoader = MockLinkContentLoader()
    detector = LinksDetector(contentLoader: mockLinkContentLoader)
  }
  
  func testEmailDetection() {
    guard let results = try? detector.detect(in: "tamer.milad6@gmail.com should be detected as a link.").toBlocking().toArray(),
      results.count == 1,
      case .linkMatches(let links) = results[0],
      links.count == 1
      else { XCTFail("Email detection fails"); return }
    
    XCTAssertEqual(links[0], "tamer.milad6@gmail.com")
  }
  
  func testHTMLLinksDetected() {
    guard let results = try? detector.detect(in: "http://www.google.com should be detected as a link.").toBlocking().toArray(),
      results.count == 1,
      case .linkMatches(let links) = results[0],
      links.count == 1
      else { XCTFail("HTML detection fails"); return }
    
    XCTAssertEqual(links[0], "http://www.google.com")
  }
  
  func testHTMLLinksWithoutSchemeDetected() {
    guard let results = try? detector.detect(in: "www.google.com should be detected as a link.").toBlocking().toArray(),
      results.count == 1,
      case .linkMatches(let links) = results[0],
      links.count == 1
      else { XCTFail("HTML detection fails"); return }
    
    XCTAssertEqual(links[0], "www.google.com")
  }
  
  func testMutlipleLinksDetected() {
    guard let results = try? detector.detect(in: "www.google.com http://www.atlassian.com tamer.milad6@gmail.com https://www.google.com.sg/?gfe_rd=cr&dcr=0&ei=uj63WqyfNdeBz7sP54eomAY should be detected as a link.").toBlocking().toArray(),
      results.count == 1,
      case .linkMatches(let links) = results[0],
      links.count == 4
      else { XCTFail("HTML detection fails"); return }
    
    XCTAssertEqual(links[0], "www.google.com")
    XCTAssertEqual(links[1], "http://www.atlassian.com")
    XCTAssertEqual(links[2], "tamer.milad6@gmail.com")
    XCTAssertEqual(links[3], "https://www.google.com.sg/?gfe_rd=cr&dcr=0&ei=uj63WqyfNdeBz7sP54eomAY")
  }
  
  func testMapMatches() {
    let googleLinkContent = LinkContent(url: "www.google.com", title: "Google")
    let atlassianLinkContent = LinkContent(url: "http://www.atlassian.com", title: "Atlassian | Software Development and Collaboration Tools")
    let gmailLinkContent = LinkContent(url: "tamer.milad6@gmail.com", title: "Gmail")
    mockLinkContentLoader.singles[googleLinkContent.url] = Observable.of(googleLinkContent).asSingle()
    mockLinkContentLoader.singles[atlassianLinkContent.url] = Observable.of(atlassianLinkContent).asSingle()
    mockLinkContentLoader.singles[gmailLinkContent.url] = Observable.of(gmailLinkContent).asSingle()
    
    let matches: [Substring] = ["www.google.com", "http://www.atlassian.com", "tamer.milad6@gmail.com"]
    
    guard let results = try? detector.map(matches: matches).toBlocking().toArray(),
      results.count == 1,
      case .links(let links) = results[0],
      links.count == 3
      else { XCTFail("Mapping failed"); return }
    
    XCTAssertEqual(links, [googleLinkContent, atlassianLinkContent, gmailLinkContent])
  }
}

class MockLinkContentLoader: LinkContentLoader {
  var singles: [String:Single<LinkContent>] = [:]
  func linkContent(from url: String) -> Single<LinkContent> {
    guard let single = singles[url]
      else { return Observable.empty().asSingle() }
    return single
  }
}
