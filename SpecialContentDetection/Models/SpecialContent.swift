//
//  SpecialContent.swift
//  ChatSpecialContent
//
//  Created by Tamer Pateer on 11/3/18.
//  Copyright © 2018 Atlassian. All rights reserved.
//

import Foundation

public enum SpecialContent {
	case mention(String)
	case emoticon(String)
	case link(LinkContent)
}

public struct LinkContent: Codable {
	let url: String
	let title: String?
}
