//
//  EmoticonsDetector.swift
//  ChatSpecialContent
//
//  Created by Tamer Pateer on 11/3/18.
//  Copyright © 2018 Atlassian. All rights reserved.
//

import RxSwift

public class EmoticonsDetector: RegExDetector, SpecialContentDetector {
  
  init() {
    super.init(pattern: "\\(\\w{1,15}\\)")!
  }
  
  public func detect(in message: String) -> Observable<SpecialContent> {
    return findMatches(in: message)
      .map { match in
        let firstIndex = match.index(after: match.index(of: "(")!)
        let lastIndex = match.index(of: ")")!
        let emoticonRange = firstIndex..<lastIndex
        return .emoticon(String(match[emoticonRange]))
    }
  }
}
