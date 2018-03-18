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
  let dispatchQueue = DispatchQueue(label: "String")
  
  init(regEx: NSRegularExpression) {
    self.regEx = regEx
  }
  
  init?(pattern: String) {
    do {
      self.regEx = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
    } catch {
      return nil
    }
  }
  
  func findMatches(in string: String) -> Observable<Substring> {
    let subject = ReplaySubject<Substring>.createUnbounded()
    dispatchQueue.async {
      let range = string.startIndex..<string.endIndex
      let nsrange = NSRange(range, in: string)
      self.regEx.enumerateMatches(in: string, options: .reportCompletion, range: nsrange) { (result, flags, _) in
        if let result = result,
          let range  = Range(result.range, in: string) {
          let match = string[range]
          subject.onNext(match)
        } else if flags.contains(.completed) {
          subject.onCompleted()
        }
      }
    }
    return subject
  }
}
