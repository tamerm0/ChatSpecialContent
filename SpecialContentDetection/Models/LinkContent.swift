//
//  LinkContent.swift
//  SpecialContentDetection
//
//  Created by Tamer Pateer on 18/3/18.
//  Copyright © 2018 Atlassian. All rights reserved.
//

import Foundation

public struct LinkContent: Codable, Equatable {
  let url: String
  let title: String?
  
  public static func ==(lhs: LinkContent, rhs: LinkContent) -> Bool {
    return lhs.url == rhs.url && lhs.title == rhs.title
  }
}
