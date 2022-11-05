//
//  BaseViewController.swift
//  LocationNote
//
//  Created by k17124kk on 2022/10/29.
//

import UIKit

class BaseViewController: UIViewController {

    lazy var router = MainRouter()

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    func modalViewController(_ vc: UIViewController, animated: Bool) {
        self.present(vc, animated: animated)
    }
}
