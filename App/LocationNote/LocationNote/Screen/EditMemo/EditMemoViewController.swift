//
//  EditMemoViewController.swift
//  LocationNote
//
//  Created by k17124kk on 2022/11/20.
//

import UIKit
import CoreLocation

class EditMemoViewController: BaseViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var tagTextField: UITextField!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var addButton: PrimaryButton!

    private var memo: Memo?

    private let viewModel = EditMemoViewModel()

    static func initFromStoryboard(memo: Memo, parent: UIAdaptivePresentationControllerDelegate) -> UIViewController {
        let storyboard = UIStoryboard(name: R.storyboard.editMemoViewController.name, bundle: nil)
        let viewController = storyboard.instantiateInitialViewController() as! EditMemoViewController

        viewController.memo = memo
        viewController.presentationController?.delegate = parent

        return NavigationViewController.init(rootViewController: viewController)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "編集"

        setNavigationBarItem()
        setLayout()
    }
}

extension EditMemoViewController {
    @objc func closeButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }

    @objc func deleteButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }

    func setNavigationBarItem() {
        let closeButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeButtonTapped(_:)))
        closeButtonItem.tintColor = R.color.white1()
        self.navigationItem.rightBarButtonItem = closeButtonItem

        let deleteButtonItem = UIBarButtonItem(title: "削除", style: .plain, target: self, action: #selector(deleteButtonTapped(_:)))
        deleteButtonItem.tintColor = R.color.red1()
        self.navigationItem.leftBarButtonItem = deleteButtonItem
    }

    func setLayout() {
        locationLabel.setLocationText(memo: self.memo!)

        titleTextField.layer.borderColor = R.color.white2()?.cgColor
        titleTextField.layer.borderWidth = 1
        titleTextField.layer.cornerRadius = 4

        detailTextView.layer.borderWidth = 1
        detailTextView.layer.borderColor = R.color.white2()?.cgColor
        detailTextView.layer.cornerRadius = 4

        tagTextField.layer.borderColor = R.color.white2()?.cgColor
        tagTextField.layer.borderWidth = 1
        tagTextField.layer.cornerRadius = 4
    }
}
