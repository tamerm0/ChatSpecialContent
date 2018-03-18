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
}

open class ChatContentDetector: Any {
	
  let schduler: ImmediateSchedulerType = ConcurrentDispatchQueueScheduler(qos: .default)
  
	public init() {}
	
	public func detectContent(in message: String, detectors: [ContentDetector]) -> Single<MessageSpecialContent> {
		return Single.create(subscribe: { [schduler] (single) -> Disposable in
			let observables = detectors
				.map { $0.detector.detect(in: message) }
			var messageContent = MessageSpecialContent()
			var disposeBag: DisposeBag? = DisposeBag()
			Observable.merge(observables)
        .observeOn(schduler)
        .subscribe(onNext: { (content) in
				messageContent.update(with: content)
			}, onCompleted: {
				single(.success(messageContent))
			}).disposed(by: disposeBag!)
			return Disposables.create {
				disposeBag = nil
			}
		})
	}
}
