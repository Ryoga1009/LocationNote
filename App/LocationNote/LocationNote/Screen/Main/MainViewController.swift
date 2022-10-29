//
//  ViewController.swift
//  LocationNote
//
//  Created by k17124kk on 2022/10/24.
//

import UIKit

class MainViewController: BaseViewController {

    static func initFromStoryboard() -> UIViewController {
        let storyboard = UIStoryboard(name: R.storyboard.main.name, bundle: nil)
        let viewController = storyboard.instantiateInitialViewController() as! MainViewController

        return UINavigationController(rootViewController: viewController)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
