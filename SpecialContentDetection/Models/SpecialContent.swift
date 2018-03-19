//
//  SpecialContent.swift
//  SpecialContentDetection
//
//  Created by Tamer Pateer on 19/3/18.
//  Copyright © 2018 Atlassian. All rights reserved.
//

enum SpecialContent {
  case mentions([String])
  case emoticons([String])
  case links([LinkContent])
}
