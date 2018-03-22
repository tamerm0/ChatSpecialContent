//
//  LinksDetector.swift
//  ChatSpecialContent
//
//  Created by Tamer Pateer on 11/3/18.
//  Copyright © 2018 Atlassian. All rights reserved.
//

import RxSwift

class LinksDetector: RegExDetector, SpecialContentDetector {
  
  let session = URLSession(configuration: .default)
  
  init() {
    let regEx = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    super.init(regEx: regEx)
  }
  
  func detect(in message: String) -> Maybe<SpecialContentMatch> {
    return findMatches(in: message)
      .map { .linkMatches($0) }
  }
  
  func map(matches: [Substring]) -> Single<SpecialContent> {
    let links = matches.map { session.linkContent(with: String($0)).asObservable() }
    return Observable.zip(links).asSingle().map { .links($0) }
  }
}

private extension URLSession {
  func linkContent(with url: String) -> Single<LinkContent> {
    return Single.create(subscribe: { (single) -> Disposable in
      let task = self.dataTask(with: URL(string: url)!) { data, response, error in
        guard let _ = data else {
          single(.success(LinkContent(url: url, title: nil)))
          return
        }
        single(.success(LinkContent(url: url, title: "title received")))
      }
      task.resume()
      return Disposables.create {
        task.cancel()
      }
    })
  }
}
