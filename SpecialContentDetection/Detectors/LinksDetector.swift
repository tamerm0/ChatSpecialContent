//
//  LinksDetector.swift
//  ChatSpecialContent
//
//  Created by Tamer Pateer on 11/3/18.
//  Copyright © 2018 Atlassian. All rights reserved.
//

import RxSwift

class LinksDetector: RegExDetector, SpecialContentDetector {
  
  init() {
    let regEx = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    super.init(regEx: regEx)
  }
  
  func detect(in message: String) -> Maybe<SpecialContentMatch> {
    return findMatches(in: message)
      .map { .linkMatches($0) }
  }
  
  func map(matches: [Substring]) -> Single<SpecialContent> {
    let links = matches.map { LinkContent(url: String($0), title: nil) }
    return Observable<SpecialContent>.of(.links(links)).asSingle()
  }
}
