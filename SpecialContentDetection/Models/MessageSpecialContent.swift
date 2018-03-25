//
//  MessageSpecialContent.swift
//  ChatSpecialContent
//
//  Created by Tamer Pateer on 11/3/18.
//  Copyright © 2018 Atlassian. All rights reserved.
//

public struct MessageSpecialContent: Codable, Equatable {
	var mentions: [String]?
	var emoticons: [String]?
	var links: [LinkContent]?
  
  mutating func update(with content: SpecialContent) {
    switch content {
    case .emoticons(let emoticons):
      self.emoticons = emoticons
    case .mentions(let mentions):
      self.mentions = mentions
    case .links(let links):
      self.links = links
    }
  }
  
  public static func ==(lhs: MessageSpecialContent, rhs: MessageSpecialContent) -> Bool {
    if let lhsMentions = lhs.mentions {
      guard let rhsMentions = rhs.mentions,
        lhsMentions == rhsMentions
        else { return false }
    } else if rhs.mentions != nil {
      return false
    }
    
    if let lhsEmoticons = lhs.emoticons {
      guard let rhsEmoticons = rhs.emoticons,
        lhsEmoticons == rhsEmoticons
        else { return false }
    } else if rhs.emoticons != nil {
      return false
    }
    
    if let lhsLinks = lhs.links {
      guard let rhsLinks = rhs.links,
        lhsLinks == rhsLinks
        else { return false }
    } else if rhs.links != nil {
      return false
    }
    
    return true
  }
}
