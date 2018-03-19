//
//  SpecialContentDetector.swift
//  ChatSpecialContent
//
//  Created by Tamer Pateer on 10/3/18.
//  Copyright © 2018 Atlassian. All rights reserved.
//

import RxSwift

protocol SpecialContentDetector: class {
	func detect(in message: String) -> Maybe<SpecialContentMatch>
  func map(matches: [Substring]) -> Single<SpecialContent>
}
