//
//  LinkContentLoader.swift
//  SpecialContentDetection
//
//  Created by Tamer Pateer on 22/3/18.
//  Copyright © 2018 Atlassian. All rights reserved.
//

import RxSwift
import Kanna

protocol LinkContentLoader {
  func linkContent(from url: String) -> Single<LinkContent>
}

class LinkContentLoaderImpl: LinkContentLoader {
  
  let session = URLSession(configuration: .default)
  
  func linkContent(from url: String) -> Single<LinkContent> {
    return Single.create(subscribe: { [session] (single) -> Disposable in
      let task = session.dataTask(with: URL(string: url)!) { data, response, error in
        guard
          let data = data,
          let html = String(data: data, encoding: .utf8),
          let htmlDocument = try? Kanna.HTML(html: html, encoding: .utf8) else {
          single(.success(LinkContent(url: url, title: nil)))
          return
        }
        single(.success(LinkContent(url: url, title: htmlDocument.title)))
      }
      task.resume()
      return Disposables.create {
        task.cancel()
      }
    })
  }
}
