//
//  LinksDetector.swift
//  ChatSpecialContent
//
//  Created by Tamer Pateer on 11/3/18.
//  Copyright © 2018 Atlassian. All rights reserved.
//

import RxSwift

class LinksDetector: RegExDetector, SpecialContentDetector {
  
  let networkLoader: LinkContentLoader
  
  init(contentLoader: LinkContentLoader = LinkContentLoaderImpl()) {
    let regEx = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    self.networkLoader = contentLoader
    super.init(regEx: regEx)
  }
  
  func detect(in message: String) -> Maybe<SpecialContentMatch> {
    return findMatches(in: message)
      .map { .linkMatches($0) }
  }
  
  func map(matches: [Substring]) -> Single<SpecialContent> {
    let links = matches.map { networkLoader.linkContent(from: String($0)).asObservable() }
    return Observable.zip(links).asSingle().map { .links($0) }
  }
}
