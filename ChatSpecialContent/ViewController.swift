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
  
  let detector = TestDetector()
  let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    detectButton.rx.tap
      .withLatestFrom(textFieldMessage.rx.text)
      .flatMap { (text) -> Observable<String> in
        guard let text = text else { return Observable.empty() }
        return Observable.of(text)
      }
      .distinctUntilChanged { $0 == $1 }
      .map { [detector] in detector.detectContent(in: $0) }
      .switchLatest()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [textViewSpecialContent] (content) in
        textViewSpecialContent?.text = content
      }).disposed(by: disposeBag)
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
  
  func detectContent(in message: String) -> Single<String> {
    return super.detectContent(in: message, detectors: [.mention, .emoticon, .link])
      .map({ [encoder] content -> Data? in try? encoder.encode(content) }) // encode to JSON data
      .map({ jsonData -> String? in jsonData.flatMap { String(data: $0, encoding: .utf8) } })
      .flatMap({ (jsonString) -> Single<String> in
        Single.create(subscribe: { (single) -> Disposable in
          if let jsonString = jsonString {
            single(.success(jsonString.replacingOccurrences(of: "\\/", with: "/")))
          } else {
            single(.error(ContentError.empty))
          }
          return Disposables.create()
        })
      })
  }
}

