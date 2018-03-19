//
//  EmoticonsDetector.swift
//  ChatSpecialContent
//
//  Created by Tamer Pateer on 11/3/18.
//  Copyright © 2018 Atlassian. All rights reserved.
//

import RxSwift

class EmoticonsDetector: RegExDetector, SpecialContentDetector {
  
  init() {
    super.init(pattern: "\\(\\w{1,15}\\)")!
  }
  
  func detect(in message: String) -> Maybe<SpecialContentMatch> {
    return findMatches(in: message)
      .map { .emoticonMatches($0.map { $0.dropFirst().dropLast() }) }
  }
  
  func map(matches: [Substring]) -> Single<SpecialContent> {
    let emoticons = matches.map { String($0) }
    return Observable<SpecialContent>.of(.emoticons(emoticons)).asSingle()
  }
}
