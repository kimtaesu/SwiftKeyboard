//
//  ViewController.swift
//  keyboard
//
//  Created by tskim on 22/01/2019.
//  Copyright © 2019 hucet. All rights reserved.
//

import UIKit

class ViewController: UIViewController, HasDisposeBag {

    @IBOutlet weak var bottomBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerAutomaticKeyboardConstraints { [weak self] height, appear in
            guard let self = self else { return }
//            self.bottomBtn.transform = appear ? CGAffineTransform(translationX: 0, y: -height) : .identity
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
}
