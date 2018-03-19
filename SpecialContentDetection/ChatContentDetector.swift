//
//  ChatContentDetector.swift
//  ChatSpecialContent
//
//  Created by Tamer Pateer on 11/3/18.
//  Copyright © 2018 Atlassian. All rights reserved.
//

import RxSwift

public enum ContentDetector {
	case mention
	case emoticon
	case link
	
	var detector: SpecialContentDetector {
    switch self {
    case .mention:
      return MentionsDetector()
    case .emoticon:
      return EmoticonsDetector()
    case .link:
      return LinksDetector()
    }
	}
  
  func matches(from matches: Matches) -> [Substring]? {
    switch self {
    case .mention:
      return matches.mentions
    case .emoticon:
      return matches.emoticons
    case .link:
      return matches.links
    }
  }
}

open class ChatContentDetector: Any {
	
  let schduler: ImmediateSchedulerType = ConcurrentDispatchQueueScheduler(qos: .default)
  
	public init() {}
	
	public func detectContent(in message: String, detectors: [ContentDetector]) -> Maybe<MessageSpecialContent> {
		return Maybe.create(subscribe: { [schduler] (maybe) -> Disposable in
			var disposeBag: DisposeBag? = DisposeBag()
      var matches = Matches()
			detectors
        .matches(in: message)
        .observeOn(schduler)
        .subscribe(onNext: { (match) in
          matches.update(with: match)
			}, onCompleted: {
        guard let disposeBag = disposeBag else { return }
        if matches.isEmpty {
          maybe(.completed)
        } else {
          matches.filterOverlaps()
          var specialContent = MessageSpecialContent()
          detectors.map(matches: matches)
            .observeOn(schduler)
            .subscribe(onNext: { (content) in
            specialContent.update(with: content)
          }, onCompleted: {
            maybe(.success(specialContent))
          }).disposed(by: disposeBag)
        }
			}).disposed(by: disposeBag!)
			return Disposables.create {
				disposeBag = nil
			}
		})
	}
}

private extension Array where Element == ContentDetector {
  
  func matches(in message: String) -> Observable<SpecialContentMatch> {
    let observables = map { $0.detector.detect(in: message).asObservable() }
    return Observable.merge(observables)
  }
  
  func map(matches: Matches) -> Observable<SpecialContent> {
    let observables = map { (detector: $0.detector, matches: $0.matches(from: matches)) }
      .flatMap({ (detector, matches) -> Single<SpecialContent>? in
        matches.map { detector.map(matches: $0) }
      }).map { $0.asObservable() }
    return Observable.merge(observables)
  }
}
