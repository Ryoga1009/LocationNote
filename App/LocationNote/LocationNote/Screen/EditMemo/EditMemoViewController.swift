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

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        guard let presentationController = presentationController else {
            return
        }
        presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
        super.dismiss(animated: flag, completion: completion)
    }
}

extension EditMemoViewController {
    @objc func closeButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }

    @objc func deleteButtonTapped(_ sender: UIBarButtonItem) {
        let deleteMemo = Memo(title: titleTextField.text ?? "", detail: detailTextView.text ?? "", tag: tagTextField.text ?? "", latitude: self.memo!.latitude, longitude: self.memo!.longitude)
        viewModel.onDeleteButtonTapped(memo: deleteMemo)
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
        titleTextField.text = memo?.title

        detailTextView.layer.borderWidth = 1
        detailTextView.layer.borderColor = R.color.white2()?.cgColor
        detailTextView.layer.cornerRadius = 4
        detailTextView.text = memo?.detail

        tagTextField.layer.borderColor = R.color.white2()?.cgColor
        tagTextField.layer.borderWidth = 1
        tagTextField.layer.cornerRadius = 4
        tagTextField.text = memo?.tag

    }
}
