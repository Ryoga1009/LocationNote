//
//  RootViewController.swift
//  LocationNote
//
//  Created by k17124kk on 2022/10/29.
//

import UIKit

class RootViewController: UIViewController {

    private var currentContent: UIViewController?
    private var router = MainRouter()

    override func viewDidLoad() {
        super.viewDidLoad()

        router.showMainScreen()
    }
}

extension RootViewController {
    func replaceContent(_ newViewController: UIViewController, animated: Bool) {
        newViewController.view.alpha = 0

        addChild(newViewController)
        view.addSubview(newViewController.view)

        UIView.animate(
            withDuration: animated ? 0.2 : 0.0,
            animations: {
                newViewController.view.alpha = 1
            },
            completion: { _ in
                newViewController.didMove(toParent: self)

                self.currentContent?.willMove(toParent: nil)
                self.currentContent?.view.removeFromSuperview()
                self.currentContent?.removeFromParent()
                self.currentContent = newViewController
            }
        )
    }
}
