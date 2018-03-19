//
//  MessageSpecialContent.swift
//  ChatSpecialContent
//
//  Created by Tamer Pateer on 11/3/18.
//  Copyright © 2018 Atlassian. All rights reserved.
//

public struct MessageSpecialContent: Codable {
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
}
