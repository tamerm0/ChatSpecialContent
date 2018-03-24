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
    super.init(pattern: "(\\s|\\W|^)\\@\\w+")!
  }
  
	func detect(in message: String) -> Maybe<SpecialContentMatch> {
    return findMatches(in: message) // find matches in message
      .map { matches in
        let cleanedMatches: [Substring] = matches.map { match in
          let index = match.index(after: match.index(of: "@")!)
          return match[index..<match.endIndex]
        }
        return .mentionMatches(cleanedMatches)
    } // remove @ from matches
	}
  
  func map(matches: [Substring]) -> Single<SpecialContent> {
    let mentions = matches.map { String($0) }
    return Observable<SpecialContent>.of(.mentions(mentions)).asSingle()
  }
}
