//
//  MainRouter.swift
//  LocationNote
//
//  Created by k17124kk on 2022/10/29.
//

import Foundation
import UIKit

struct MainRouter {
    private var sceneDelegate: SceneDelegate {
        return UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate
    }

    private var rootViewController: RootViewController {
        sceneDelegate.window?.rootViewController as! RootViewController
    }

    func replaceViewController(_ vc: UIViewController, animated: Bool) {
        rootViewController.replaceContent(vc, animated: animated)
    }

    func showMainScreen() {
        replaceViewController(MainViewController.initFromStoryboard(), animated: false)
    }
}
