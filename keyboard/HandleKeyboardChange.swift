//
//  AAA.swift
//  keyboard
//
//  Created by tskim on 22/01/2019.
//  Copyright © 2019 hucet. All rights reserved.
import RxSwift
import UIKit
import RxCocoa

var onChangedKeyboardFrameKey = "onChangedKeyboardFrameKey"

protocol HandleKeyboardChange: class, AssociatedObjectStore { }

extension HandleKeyboardChange {
    var onChangedKeyboardFrame: ((CGFloat, Bool) -> Void)? {
        get { return self.associatedObject(forKey: &onChangedKeyboardFrameKey) }
        set {
            self.setAssociatedObject(newValue, forKey: &onChangedKeyboardFrameKey)
        }
    }
}
extension HandleKeyboardChange where Self: UIViewController, Self: HasDisposeBag {
    func registerAutomaticKeyboardConstraints(_ onChanged: @escaping (CGFloat, Bool) -> Void) {
        self.onChangedKeyboardFrame = onChanged
        self.rx.viewWillDisappear
            .asDriver()
            .drive(onNext: { _ in
                NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
                NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            })
            .disposed(by: disposeBag)
        
        self.rx.viewWillAppear
            .asDriver()
            .drive(onNext: { _ in
                NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            })
            .disposed(by: disposeBag)
    }
}

extension UIViewController: HandleKeyboardChange {
    @objc
    func keyboardWillHide(_ notification: Notification) {
        handleKeyboardChanged(notification: notification, isAppearing: false)
    }
    @objc
    func keyboardWillShow(_ notification: Notification) {
        handleKeyboardChanged(notification: notification, isAppearing: true)
    }
    fileprivate func handleKeyboardChanged(notification: Notification, isAppearing: Bool) {
        guard let userInfo = notification.userInfo as? [String: Any] else { return }
        guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        guard userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber != nil else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        let heightConstant = (keyboardHeight) * (isAppearing ? 1 : -1)
        self.onChangedKeyboardFrame?(heightConstant - self.view.safeAreaInsets.bottom, isAppearing)
    }
}

public extension Reactive where Base: UIViewController {
    public var viewWillAppear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewWillAppear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    public var viewWillDisappear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewWillDisappear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
}
