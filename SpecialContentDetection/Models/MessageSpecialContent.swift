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
	
	public mutating func update(with content: SpecialContent) {
		switch content {
		case .emoticon(let emoticon):
      if emoticons == nil { emoticons = [] }
			emoticons?.append(emoticon)
		case .mention(let mention):
      if mentions == nil { mentions = [] }
			mentions?.append(mention)
		case .link(let link):
      if links == nil { links = [] }
			links?.append(link)
		}
	}
}
