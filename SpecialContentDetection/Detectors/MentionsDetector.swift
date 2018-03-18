//
//  MentionsDetector.swift
//  ChatSpecialContent
//
//  Created by Tamer Pateer on 11/3/18.
//  Copyright © 2018 Atlassian. All rights reserved.
//

import RxSwift

public class MentionsDetector: RegExDetector, SpecialContentDetector {
	
  init() {
    super.init(pattern: "\\@\\w+")!
  }
  
	public func detect(in message: String) -> Observable<SpecialContent> {
    return findMatches(in: message)
      .map { match in
        let firstIndex = match.index(after: match.index(of: "@")!)
        let mentionRange = firstIndex..<match.endIndex
        return .mention(String(match[mentionRange]))
    }
	}
}
