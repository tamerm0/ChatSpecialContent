//
//  LinkContentLoader.swift
//  SpecialContentDetection
//
//  Created by Tamer Pateer on 22/3/18.
//  Copyright © 2018 Atlassian. All rights reserved.
//

import RxSwift
import Kanna
import Alamofire

protocol LinkContentLoader {
  func linkContent(from url: String) -> Single<LinkContent>
}

class LinkContentLoaderImpl: LinkContentLoader {
  
  func linkContent(from url: String) -> Single<LinkContent> {
    return Single.create(subscribe: { (single) -> Disposable in
      // Adding HTTP scheme
      guard var httpUrl = URL(string: url) else {
//        single(.error())
        return Disposables.create()
      }
      if httpUrl.scheme == nil {
        httpUrl = URL(string: "http://" + url)!
      }
      
      let request = Alamofire.request(httpUrl)
      request.responseString(completionHandler: { (response) in
        guard let html = response.result.value,
          let htmlDocument = try? Kanna.HTML(html: html, encoding: .utf8)
          else {
            single(.success(LinkContent(url: url, title: nil)))
            return
        }
        let title = htmlDocument.title?.trimmingCharacters(in: .whitespacesAndNewlines)
        single(.success(LinkContent(url: url, title: title)))
      })
      return Disposables.create {
        request.cancel()
      }
    })
  }
}
