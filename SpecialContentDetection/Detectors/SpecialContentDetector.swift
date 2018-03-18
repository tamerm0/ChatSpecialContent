//
//  SpecialContentDetector.swift
//  ChatSpecialContent
//
//  Created by Tamer Pateer on 10/3/18.
//  Copyright © 2018 Atlassian. All rights reserved.
//

import RxSwift

public protocol SpecialContentDetector: class {
	func detect(in message: String) -> Observable<SpecialContent>
}
