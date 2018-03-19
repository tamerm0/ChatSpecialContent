//
//  MentionsDetector.swift
//  ChatSpecialContent
//
//  Created by Tamer Pateer on 11/3/18.
//  Copyright © 2018 Atlassian. All rights reserved.
//

import RxSwift

class MentionsDetector: RegExDetector, SpecialContentDetector {
	
  init() {
    super.init(pattern: "\\@\\w+")!
  }
  
	func detect(in message: String) -> Maybe<SpecialContentMatch> {
    return findMatches(in: message) // find matches in message
      .map { .mentionMatches($0.map { $0.dropFirst() }) } // remove @ from matches
	}
  
  func map(matches: [Substring]) -> Single<SpecialContent> {
    let mentions = matches.map { String($0) }
    return Observable<SpecialContent>.of(.mentions(mentions)).asSingle()
  }
}
