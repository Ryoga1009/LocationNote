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
    func replaceContent(_ newContentViewController: UIViewController, animated: Bool) {
        newContentViewController.view.alpha = 0

        addChild(newContentViewController)
        view.addSubview(newContentViewController.view)

        UIView.animate(
            withDuration: animated ? 0.2 : 0.0,
            animations: {
                newContentViewController.view.alpha = 1
            },
            completion: { _ in
                newContentViewController.didMove(toParent: self)

                self.currentContent?.willMove(toParent: nil)
                self.currentContent?.view.removeFromSuperview()
                self.currentContent?.removeFromParent()
                self.currentContent = newContentViewController
            }
        )
    }
}
