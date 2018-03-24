//
//  RegExDetector.swift
//  SpecialContentDetection
//
//  Created by Tamer Pateer on 12/3/18.
//  Copyright © 2018 Atlassian. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class RegExDetector: Any {
  
  let regEx: NSRegularExpression
  let dispatchQueue: DispatchQueue
  
  init(regEx: NSRegularExpression) {
    self.regEx = regEx
    dispatchQueue = DispatchQueue(label: regEx.pattern, attributes: .concurrent)
  }
  
  init?(pattern: String) {
    do {
      self.regEx = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
      dispatchQueue = DispatchQueue(label: pattern, attributes: .concurrent)
    } catch {
      return nil
    }
  }
  
  func findMatches(in string: String) -> Maybe<[Substring]> {
    return Maybe.create(subscribe: { [dispatchQueue] (maybe) -> Disposable in
      dispatchQueue.async {
        let range = string.startIndex..<string.endIndex
        let nsrange = NSRange(range, in: string)
        let matches = self.regEx
          .matches(in: string, options: .reportCompletion, range: nsrange)
          .map({ (result) -> Substring in
            let range  = Range(result.range, in: string)!
            let match = string[range]
            return match
          })
        if matches.isEmpty {
          maybe(.completed)
        } else {
          maybe(.success(matches))
        }
      }
      return Disposables.create()
    })
  }
}
