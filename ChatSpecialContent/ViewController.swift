//
//  ViewController.swift
//  ChatSpecialContent
//
//  Created by Tamer Pateer on 12/3/18.
//  Copyright © 2018 Atlassian. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SpecialContentDetection

class ViewController: UIViewController {
  
  @IBOutlet weak var textFieldMessage: UITextField!
  @IBOutlet weak var textViewSpecialContent: UITextView!
  @IBOutlet weak var detectButton: UIButton!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  let detector = TestDetector()
  let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    activityIndicator.isHidden = true
    detectButton.rx.tap
      .withLatestFrom(textFieldMessage.rx.text)
      .flatMap { (text) -> Observable<String> in
        guard let text = text else { return Observable.empty() }
        return Observable.of(text)
      }
      .distinctUntilChanged { $0 == $1 }
      .do(onNext: { [textViewSpecialContent, activityIndicator] (message) in
        textViewSpecialContent?.text = ""
        activityIndicator?.isHidden = false
        activityIndicator?.startAnimating()
      })
      .map { [activityIndicator, detector] in detector.detectContent(in: $0)
        .observeOn(MainScheduler.asyncInstance)
        .do(onCompleted: { [activityIndicator] in
          activityIndicator?.isHidden = true
          activityIndicator?.stopAnimating()
        })
      }
      .switchLatest()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [textViewSpecialContent] (content) in
        textViewSpecialContent?.text = content
      })
      .disposed(by: disposeBag)
  }
}

class TestDetector: ChatContentDetector {
  
  enum ContentError: Error {
    case empty
  }
  
  let encoder: JSONEncoder = JSONEncoder()
  
  override init() {
    encoder.outputFormatting = .prettyPrinted
  }
  
  func detectContent(in message: String) -> Maybe<String> {
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

