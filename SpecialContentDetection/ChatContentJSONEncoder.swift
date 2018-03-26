//
//  ChatContentJSONEncoder.swift
//  ChatSpecialContent
//
//  Created by Tamer Pateer on 26/3/18.
//  Copyright © 2018 Atlassian. All rights reserved.
//

import RxSwift

public class ChatContentJSONEncoder: ChatContentDetector {
  
  public enum ContentError: Error {
    case empty
  }
  
  let encoder: JSONEncoder = JSONEncoder()
  
  public init(formatting: JSONEncoder.OutputFormatting = .prettyPrinted) {
    encoder.outputFormatting = formatting
    super.init()
  }
  
  public func detectContent(in message: String) -> Maybe<String> {
    return super.detectContent(in: message, types: [.mention, .emoticon, .link])
      .map({ [encoder] content -> Data? in try? encoder.encode(content) }) // encode to JSON data
      .map({ jsonData -> String? in jsonData.flatMap { String(data: $0, encoding: .utf8) } })
      .flatMap({ (jsonString) -> Maybe<String> in
        Maybe.create(subscribe: { (maybe) -> Disposable in
          if let jsonString = jsonString {
            maybe(.success(jsonString.replacingOccurrences(of: "\\/", with: "/")))
          } else {
            maybe(.error(ContentError.empty))
          }
          return Disposables.create()
        })
      })
  }
}
