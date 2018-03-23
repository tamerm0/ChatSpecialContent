//
//  SpecialContentMatches.swift
//  SpecialContentDetection
//
//  Created by Tamer Pateer on 18/3/18.
//  Copyright © 2018 Atlassian. All rights reserved.
//

struct Matches {
  var mentions: [Substring]?
  var emoticons: [Substring]?
  var links: [Substring]?
  
  mutating func update(with match: SpecialContentMatch) {
    switch match {
    case .emoticonMatches(let emoticonsMatches):
      self.emoticons = emoticonsMatches
    case .mentionMatches(let mentionsMatches):
      self.mentions = mentionsMatches
    case .linkMatches(let linksMatches):
      self.links = linksMatches
    }
  }
  
  mutating func filterOverlaps() {
    guard let links = links else { return }
    
    mentions = (mentions?.filterOverlaps(with: links))
      .flatMap { $0.isEmpty ? nil : $0 }
    emoticons = (emoticons?.filterOverlaps(with: links))
      .flatMap { $0.isEmpty ? nil : $0 }
  }
  
  var isEmpty: Bool {
    return mentions == nil && emoticons == nil && links == nil
  }
}

private extension Array where Element == Substring {
  func filterOverlaps(with array: [Substring]) -> [Substring] {
    return filter({ (substring1) -> Bool in
      !array.contains(where: { (substring2) -> Bool in
        let range1 = substring1.startIndex..<substring1.endIndex
        let range2 = substring2.startIndex..<substring2.endIndex
        return range1.overlaps(range2)
      })
    })
  }
}
