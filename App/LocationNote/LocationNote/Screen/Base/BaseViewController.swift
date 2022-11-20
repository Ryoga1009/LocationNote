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

extension BaseViewController {

    func showAleart(title: String, subtitle: String?, confirmButtonTitle: String, onConfirm: @escaping () -> Void) {
        let alert: UIAlertController = UIAlertController(title: title, message: subtitle, preferredStyle: UIAlertController.Style.alert)

        let confirmAction: UIAlertAction = UIAlertAction(title: confirmButtonTitle, style: UIAlertAction.Style.default, handler: {(_: UIAlertAction!) -> Void in
            onConfirm()
        })

        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: { _ in})

        alert.addAction(cancelAction)
        alert.addAction(confirmAction)

        present(alert, animated: true, completion: nil)
    }
}
