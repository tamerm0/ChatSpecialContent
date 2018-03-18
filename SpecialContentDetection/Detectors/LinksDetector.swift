//
//  LinksDetector.swift
//  ChatSpecialContent
//
//  Created by Tamer Pateer on 11/3/18.
//  Copyright © 2018 Atlassian. All rights reserved.
//

import RxSwift

public class LinksDetector: RegExDetector, SpecialContentDetector {
  
  init() {
    let regEx = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    super.init(regEx: regEx)
  }
  
  public func detect(in message: String) -> Observable<SpecialContent> {
    return findMatches(in: message)
      .map { .link(LinkContent(url: String($0), title: nil)) }
  }
}
