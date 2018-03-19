//
//  SpecialContent.swift
//  ChatSpecialContent
//
//  Created by Tamer Pateer on 11/3/18.
//  Copyright © 2018 Atlassian. All rights reserved.
//

import Foundation

enum SpecialContentMatch {
	case mentionMatches([Substring])
	case emoticonMatches([Substring])
	case linkMatches([Substring])
}
